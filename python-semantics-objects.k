require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-OBJECTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax ObjRef ::= "init" "(" Exp "," Exp "," List "," Map ")" [strict(1, 2)] 
                  | "mroMerge" "(" KList ")"
  syntax KList ::= "getMros" "(" List ")" [function]
  syntax Bool ::= "notInTail" "(" Object "," List ")" [function]
  syntax List ::= "trimHead" "(" List "," Object ")" [function] 

  rule <k> invokeBuiltin(obj("call_type",_), ListItem(Type:Object) L:List, M:Map) => init(doCall(Type . String2Id("__new__"), ListItem(Type) L, M), Type, L, M) ...</k>

  rule <k> init(O:Object, Type, L, M) => test(istype(O, Type), test(plbool(doCall(getmember(O, "__init__", true, false, false), L, M) is ref("None")), ref(id(O)), raiseInternal("TypeError", "__init__() should return None")), O) ...</k>
 
  // since object is the base class of absolutely everything, we need object.__new__ to fail if we
  // call it with any other builtin type.
  rule <k> invokeBuiltin(obj("new_object",_), ListItem(O:Object) _, _) => newHelper(O, ref("object"), Objects -Set SetItem("object")) ~> mutable(., O) ...</k>
       <builtinObjectsWithNewMethod> Objects:Set </builtinObjectsWithNewMethod>

  rule [init-object]: <k> invokeBuiltin(obj("init_object",_), _, _) => ref("None") ...</k>

  rule <k> invokeBuiltin(obj("eq_object",_), ListItem(O) ListItem(O2:Object), .) => test(plbool(O is O2), ref("True"), ref("NotImplemented")) ...</k>
  rule <k> invokeBuiltin(obj("ne_object",_), ListItem(O) ListItem(O2), .) => not (O == O2) ...</k>
 
  syntax Test ::= hasDuplicates(List) [function]
  rule hasDuplicates(ListItem(B) L:List) => true when B in Setify(L)
  rule hasDuplicates((ListItem(B) => .) L:List) when notBool B in Setify(L)
  rule hasDuplicates(.) => false

  rule [getMro]: getMro(O:Object, Bases:Object) => test(hasDuplicates(Idify(listvalue(Bases))), raiseInternal("TypeError", "duplicate base class object"), mroMerge(list(ListItem(list(ListItem(O)))),,getMros(listvalue(Bases)),,list(ListItem(list(listvalue(Bases))))))
  context mroMerge(_,,HOLE,,_)
  context mroMerge(_,,list(_ ListItem(HOLE) _),,_)
  context mroMerge(_,,list(_ ListItem(list(_ ListItem(HOLE) _)) _),,_)
  rule getMros(ListItem(B) L:List) => list(ListItem(getMro(B, getref2(B, "__bases__")))) ,, getMros(L)
  rule getMros(.List) => .KList
  rule mroMerge(((list(L:List),,list(L2:List)) => list(L L2)),,_) when all(L L2, isMroReady)
  rule (. => list(.) ~> 0) ~> mroMerge(list(L))
  rule list(_ (. => ListItem(B))) ~> (N:Int => 0) ~> mroMerge(list((L:List => trimHead(L, B)) ListItem(list((ListItem(B:Object) => .) _)) (L2:List => trimHead(L2, B)))) when lengthList L ==Int N andBool notInTail(B, L L2)
  rule notInTail(B, ListItem(list(ListItem(_) L)) L2) => notBool(B in Setify(L)) andBool notInTail(B, L2) 
  rule notInTail(B, .) => true 
  rule trimHead(ListItem(list(ListItem(B) L:List)) L2:List, B2) => ListItem(#if B ==K B2 #then list(L) #else list(ListItem(B) L) #fi) trimHead(L2, B2) 
  rule trimHead(., _) => . 
  rule list(_) ~> _ ~> mroMerge(list(_ (ListItem(list(.)) => .) _))
  rule list(_) ~> (N:Int => N +Int 1) ~> mroMerge(list(L:List ListItem(list(ListItem(B:Object) _)) L2:List)) when lengthList L ==Int N andBool notBool notInTail(B, L L2)
  rule list(_) ~> N:Int ~> mroMerge(list(L)) => raiseInternal("TypeError", "Cannot create a consistent method resolution order (MRO)") when N ==Int lengthList(L) andBool L =/=List .
  rule [getMro-finish]: list(L => Refify(Idify(L))) ~> (_:Int ~> mroMerge(list(.)) => .)
  context mutable(HOLE,_) when getKLabel HOLE ==KLabel 'getMro
  context immutable(HOLE,_) when getKLabel HOLE ==KLabel 'getMro

  syntax KLabel ::= "isMroReady"

  rule isMroReady(list(L:List)) => all(L, isObject)

  rule invokeBuiltin(obj("mro_type",_), ListItem(Type), .) => mutable(getMro(Type, getref(Type, "__bases__")), ref("list"))

  rule invokeBuiltin(obj("setattr",_), ListItem(O) ListItem(Name:Object) ListItem(Value:Object), .) => getmember(O, "__setattr__", true, false, true) (Name, Value)

  rule invokeBuiltin(obj("object.__setattr__",_), ListItem(O) ListItem(Name) ListItem(Value), .) => test(istype(O, ref("type")), raiseInternal("TypeError", "can't apply this __setattr__ to type object"), setmember(O, Name, Value))
  rule invokeBuiltin(obj("module.__setattr__",_), ListItem(O) ListItem(Name) ListItem(Value), .) => setmember(O, Name, Value)
  rule invokeBuiltin(obj("type.__setattr__",_), ListItem(Type) ListItem(Name) ListItem(Value), .) => setmember(Type, Name, Value)

  rule invokeBuiltin(obj("set_ref_dict",_), ListItem(Self) ListItem(Instance) ListItem(Value), .) => test(istype(Value, ref("dict")), setref(id(Instance), getattr(Self, "__get__"), Value), raiseInternal("TypeError", getattr(Self, "__get__") +String " must be set to a dictionary"))

  rule invokeBuiltin(obj("subclasshook_object",_), L:List, .) => ref("NotImplemented")
  rule invokeBuiltin(obj("instancecheck_type",_), ListItem(Self) ListItem(Instance), .) => bool(istype(Instance, Self))
  rule invokeBuiltin(obj("subclasscheck_type",_), ListItem(Self) ListItem(Subclass), .) => bool(hasbase(Subclass, Self))

  rule invokeBuiltin(obj("isinstance",_), ListItem(Instance:Object) ListItem(Class:Object), .) => test(istype(Class, ref("tuple")), AnyIsInstance(Instance, listvalue(Class)), test(istype(Class, ref("type")), getmember(Class, "__instancecheck__", true, false, true)(Instance), raiseInternal("TypeError", "isinstance() arg 2 must be a type or tuple of types")))
  rule invokeBuiltin(obj("issubclass",_), ListItem(Subclass:Object) ListItem(Class:Object), .) => test(istype(Class, ref("tuple")), AnyIsSubclass(Subclass, listvalue(Class)), test(istype(Class, ref("type")), getmember(Class, "__subclasscheck__", true, false, true)(Subclass), raiseInternal("TypeError", "issubclass() arg 2 must be a class or tuple of classes")))
  syntax Exp ::= AnyIsInstance(Object, List)
               | AnyIsSubclass(Object, List)
  context AnyIsInstance(_, ListItem(HOLE) _)
  context AnyIsSubclass(_, ListItem(HOLE) _)
  rule AnyIsInstance(Instance, ListItem(O:Object) L) => ref("isinstance")(Instance, O) or AnyIsInstance(Instance, L)
  rule AnyIsSubclass(Subclass, ListItem(O:Object) L) => ref("issubclass")(Subclass, O) or AnyIsSubclass(Subclass, L)
  rule AnyIsInstance(_, .List) => ref("False")
  rule AnyIsSubclass(_, .List) => ref("False")

  rule invokeBuiltin(obj("NoneType.__new__",_), ListItem(Cls), .) => newHelper(Cls, ref("NoneType"), .) ~> ref("None")

endmodule
