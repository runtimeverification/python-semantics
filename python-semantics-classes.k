require "python-semantics-calls.k"

module PYTHON-SEMANTICS-CLASSES
  imports PYTHON-SEMANTICS-CALLS

  //TODO: staticmethod

  syntax ObjRef ::= makeType(Exp, Exp) [strict]
                  | invokeClass(Exp, Exp, Exp, Map) [strict(1, 2, 3)]
                  | executeClass(Exp, Exp, Exp, Exp, Exp, Exp, Map) [strict(1, 2, 3, 4, 5, 6)] 
                  | calculateMetaclass(Exp, Exp, Exp, Exp, Exp) [strict]
                  | setClass(Exp, Exp, Exp) [strict]

  syntax K ::= restoreContext(List, List, Int)
             | setWinner(Exp) [strict]
  rule class(Args, CO:Object) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeClass(getMetaclass(Args), CO, .Obj, .) when isKResult(Args)

  rule invokeClass(Metaclass:Object, CO:Object, Bases:Object, M:Map) => executeClass(Metaclass, CO, Bases, ref("builtins"), ref("globals")(.Arguments), doCall(Metaclass . String2Id("__prepare__"), ListItem(CO . String2Id("co_name")) ListItem(Bases), M), M)

  rule <k> executeClass(Metaclass:Object, CO:Object, Bases:Object, Builtins:Object, Globals:Object, Locals:Object, M:Map) => executeFrame(N, CO, ref(Back), Locals, Globals, Builtins, makeCells(CO . String2Id("co_freevars"), CO . String2Id("co_cellvars"), ref("tuple")(ref("map")(getref2(ref(Back), "f_cells") . String2Id("__getitem__"), CO . String2Id("co_freevars"))), N), .) ~> ((Locals["__module__"]) = ref("globals")(.Arguments) . String2Id("get")("__name__", "builtins")) ~> (if CO . String2Id("co_consts")[0] is not ref("None") : (Locals["__doc__"]) = CO . String2Id("co_consts")[0] else: pass) ~> restoreContext(LL, FL, Back) ~> setClass(doCall(Metaclass, ListItem(CO . String2Id("co_name")) ListItem(Bases) ListItem(Locals), M), CO, ref(N)) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <frameObject> Back:Int </frameObject>
       <fstack> FL => . </fstack>
       <lstack> LL => . </lstack> [allocation]

 rule setClass(Cls:Object, CO:Object, Frame:Object) => doBind("__class__", ref(id(Cls)), Frame) ~> Cls

 rule <k> restoreContext(LL, FL, N) => . ...</k>
      <fstack> _ => FL </fstack>
      <lstack> _ => LL </lstack>
      <frameObject> _ => N </frameObject>

  rule (processArgs(L:List, M:Map, .Obj, .Obj) => .) ~> invokeClass(_, _, (.Obj => immutable(list(Refify(Idify(L))), ref("tuple"))), (. => stripMetaclass(M)))

  syntax Exp ::= getMetaclass(Arguments) [function]
  rule getMetaclass(X = E:Exp, _) => E when Id2String(X) ==String "metaclass" 
  rule getMetaclass(Arg, K:K) => getMetaclass(K) when getKLabel Arg =/=KLabel '_=_ 
  rule getMetaclass(.Exps) => ref("type") 

  syntax Map ::= stripMetaclass(Map) [function]
  rule stripMetaclass("metaclass" |-> K M) => stripMetaclass(M) 
  rule stripMetaclass(S:String |-> K M) => S |-> K stripMetaclass(M) when S=/=String "metaclass" 
  rule stripMetaclass(.) => . 

  rule invokeBuiltin(obj("prepare_type",_), _, _) => {.KeyData}

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(O:Object), _) => newHelper(Type, ref("type"), .Set) ~> getref(O, "__class__")
  
  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(O:Object) ListItem(O2:Object), _) => newHelper(Type, ref("type"), .Set) ~> raiseInternal("TypeError", "type() takes 1 or 3 arguments")

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(Name:Object) ListItem(Bases:Object) ListItem(Dict:Object), _) => newHelper(Type, ref("type"), .Set) ~> test(istype(Name, ref("str")), test(istype(Bases, ref("tuple")), test(istype(Dict, ref("dict")), calculateMetaclass(Name, Bases, Type, Dict, Type), raiseInternal("TypeError", "type() argument 3 must be dict")), raiseInternal("TypeError", "type() argument 2 must be tuple")), raiseInternal("TypeError", "type() argument 1 must be str"))

  rule (. => iterate(Bases, .)) ~> calculateMetaclass(_, Bases, _, _, _)
  rule (. => if gettype(O) is ref("type") or bool(hasbase(Winner, gettype(O))) : pass else: test(hasbase(gettype(O), Winner), setWinner(gettype(O)), raiseInternal("TypeError", "metaclass conflict: the metaclass of a derived class must be a (non-strict) subclass of the metaclasses of all its bases"))) ~> list((ListItem(O) => .) _) ~> calculateMetaclass(_, _, _, _, Winner)
  rule (setWinner(O:Object) => .) ~> list(_) ~> calculateMetaclass(_, _, _, _, (_ => O))
  rule list(.) ~> calculateMetaclass(Name, Bases, Type, Dict:Object, Type) => makeType(mutable("__name__" |-> strvalue(Name) "__bases__" |-> ref(id(Bases)), Type), ref("dict")(Dict))
  rule list(.) ~> calculateMetaclass(Name:Object, Bases:Object, Type, Dict:Object, Winner:Object) => Winner . String2Id("__new__") (Winner, Name, Bases, Dict) when Winner =/=K Type

  rule makeType(O:Object, Dict:Object) => (if "__doc__" not in Dict : Dict["__doc__"] = ref("None") else: pass) ~> (if "__module__" not in Dict : Dict["__module__"] = ref("globals")(.Arguments) . String2Id("get")("__name__", "builtins") else: pass) ~> (if getref(O, "__bases__") == tuple(.Exps) : setref(id(O), "__bases__", tuple(ref("object"))) else: pass) ~> (if "__hash__" not in Dict and "__eq__" in Dict : Dict["__hash__"] = ref("None") else: pass) ~> (if "__new__" in Dict and bool(istype(Dict["__new__"], ref("function"))) : Dict["__new__"] = ref("staticmethod")(Dict["__new__"]) else: pass) ~> Dict["__dict__"] = ref("object.__dict__") ~> setref(id(O), "__dict__", Dict) ~> setref(id(O), "__mro__", ref("tuple")(getmember(O, "mro", true, false, true) (.Arguments))) ~> ref(id(O))

endmodule
