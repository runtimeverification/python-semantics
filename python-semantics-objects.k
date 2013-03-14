require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-OBJECTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax ObjRef ::= "init" "(" Expression "," Expression "," List "," Map ")" [strict(1, 2)] 
                  | "getMros" "(" List ")"
                  | "mroMerge" "(" KList ")"
  syntax Bool ::= "notInTail" "(" ObjId "," List ")" [function]
  syntax List ::= "trimHead" "(" List "," ObjId ")" [function] 

  //rule <k> invokeBuiltin(obj("call_type",_), ListItem(Type:Object) L:List, M:Map) => init(doCall(Type . String2Id("__new__"), ListItem(Type) L, M), Type, L, M) ...</k>

  rule <k> init(O:Object, Type, L, M) => test(istype(O, Type), test(plbool(doCall(getmember(O, "__init__", true, false, false), L, M) is ref("None")), ref(id(O)), raiseInternal("TypeError", "__init__() should return None")), O) ...</k>

  //rule <k> invokeBuiltin(obj("new_object",_), ListItem(O:Object) _, _) => newHelper(O, ref("object"), SetItem("iterator") SetItem("attribute") SetItem("builtin-function") SetItem("builtin-method") SetItem("frame") SetItem("reference")) ~> (if O is not ref("object") : setref(N, "__dict__", {.KeyData}) else: pass) ~> ref(N) ...</k>
  //     <nextLoc> N:Nat => N +Int 1 </nextLoc>
  //     (. => <object>
  //       <id>N</id>
  //       <oattrs> "__class__" |-> ref(id(O)) </oattrs>
  //     </object>) [allocation]

//  rule [init-object]: <k> invokeBuiltin(obj("init_object",_), _, _) => ref("None") ...</k>

  //rule <k> invokeBuiltin(obj("eq_object",_), ListItem(O) ListItem(O2:Object), .) => test(plbool(O is O2), ref("True"), ref("NotImplemented")) ...</k>
  //rule <k> invokeBuiltin(obj("ne_object",_), ListItem(O) ListItem(O2), .) => not (O == O2) ...</k>
 
  rule [getMro]: getMro(O:Object, Bases:Object) => mroMerge(list(ListItem(list(ListItem(O)))),,getMros(listvalue(Bases)),,list(ListItem(list(listvalue(Bases)))))
  context mroMerge(_,,HOLE,,_)
  context mroMerge(_,,list(_ ListItem(HOLE) _),,_)
  context mroMerge(_,,list(_ ListItem(list(_ ListItem(HOLE) _)) _),,_)
  rule getMros(ListItem(B) L:List) => list(ListItem(getMro(B, getref2(B, "__bases__")))) ,, getMros(L)
  rule getMros(.List) => .KList
  rule mroMerge(((list(L:List),,list(L2:List)) => list(L L2)),,_) when all(L L2, isMroReady)
  rule (. => list(.) ~> 0) ~> mroMerge(list(L))
  rule list(_ (. => ListItem(B))) ~> (N:Int => 0) ~> mroMerge(list((L:List => trimHead(L, B)) ListItem(list((ListItem(B:Object) => .) _)) (L2:List => trimHead(L2, B)))) when lengthList L ==Int N andBool notInTail(B, L L2)
  rule notInTail(B, ListItem(list(ListItem(_) L)) L2) => notBool(B in Setify(L)) andBool notInTail(B, L2) [function, anywhere]
  rule notInTail(B, .) => true [function, anywhere]
  rule trimHead(ListItem(list(ListItem(B) L:List)) L2:List, B2) => ListItem(#if B ==K B2 #then list(L) #else list(ListItem(B) L) #fi) trimHead(L2, B2) [function, anywhere]
  rule trimHead(., _) => . [function, anywhere]
  rule list(_) ~> _ ~> mroMerge(list(_ (ListItem(list(.)) => .) _))
  rule list(_) ~> (N:Int => N +Int 1) ~> mroMerge(list(L:List ListItem(list(ListItem(B:Object) _)) L2:List)) when lengthList L ==Int N andBool notBool notInTail(B, L L2)
  rule list(_) ~> N:Int ~> mroMerge(list(L)) => raiseInternal("TypeError", "Cannot create a consistent method resolution order (MRO)") when N ==Int lengthList(L) andBool L =/=List .
  rule [getMro-finish]: list(L => Refify(Idify(L))) ~> (_:Int ~> mroMerge(list(.)) => .)
  context mutable(HOLE,_) when getKLabel HOLE ==KLabel 'getMro
  context immutable(HOLE,_) when getKLabel HOLE ==KLabel 'getMro

  syntax KLabel ::= "isMroReady"

  rule isMroReady(list(L:List)) => all(L, isObject)

  //rule invokeBuiltin(obj("mro_type",_), ListItem(Type), .) => mutable(getMro(Type, getref(Type, "__bases__")), ref("list"))

  //rule invokeBuiltin(obj("setattr",_), ListItem(O) ListItem(Name:Object) ListItem(Value:Object), .) => getmember(O, "__setattr__", true, false, true) (Name, Value)

  //rule invokeBuiltin(obj("setattr_object",_), ListItem(O) ListItem(Name) ListItem(Value), .) => test(istype(O, ref("type")), raiseInternal("TypeError", "can't apply this __setattr__ to type object"), setmember(O, Name, Value))
  //rule invokeBuiltin(obj("setattr_type",_), ListItem(Type) ListItem(Name) ListItem(Value), .) => setmember(Type, Name, Value)

  //rule invokeBuiltin(obj("subclasshook_object",_), L:List, .) => ref("NotImplemented")
  //rule invokeBuiltin(obj("instancecheck_type",_), ListItem(Self) ListItem(Instance), .) => bool(istype(Instance, Self))
  //rule invokeBuiltin(obj("subclasscheck_type",_), ListItem(Self) ListItem(Subclass), .) => bool(hasbase(Subclass, Self))

  //rule invokeBuiltin(obj("isinstance",_), ListItem(Instance) ListItem(Class), .) => getmember(Class, "__instancecheck__", true, false, true)(Instance, .Arguments)
  //rule invokeBuiltin(obj("issubclass",_), ListItem(Subclass) ListItem(Class), .) => getmember(Class, "__subclasscheck__", true, false, true)(Subclass, .Arguments) 

endmodule
