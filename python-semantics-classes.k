require "python-semantics-calls.k"

module PYTHON-SEMANTICS-CLASSES
  imports PYTHON-SEMANTICS-CALLS

  //TODO: staticmethod

  syntax ObjRef ::= makeType(Expression, Expression) [strict]
                  | invokeClass(Expression, Expression, Expression, Map) [strict(1, 2, 3)]
                  | executeClass(Expression, Expression, Expression, Expression, Expression, Expression, Map) [strict(1, 2, 3, 4, 5, 6)] 
                  | calculateMetaclass(Expression, Expression, Expression, Expression, Expression) [strict]

  syntax K ::= restoreContext(List, List, Int)
             | setWinner(Expression) [strict]
  rule class(Args, CO:Object) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeClass(getMetaclass(Args), CO, .Obj, .) when isKResult(Args)

  rule invokeClass(Metaclass:Object, CO:Object, Bases:Object, M:Map) => executeClass(Metaclass, CO, Bases, ref("builtins"), ref("globals")(.Arguments), doCall(Metaclass . String2Id("__prepare__"), ListItem(CO . String2Id("co_name")) ListItem(Bases), M), M)

  rule <k> executeClass(Metaclass:Object, CO:Object, Bases:Object, Builtins:Object, Globals:Object, Locals:Object, M:Map) => executeFrame(N, CO, ref(Back), Locals, Globals, Builtins, makeCells(CO . String2Id("co_freevars"), CO . String2Id("co_cellvars"), ref("tuple")(ref("map")(getref2(ref(Back), "f_cells") . String2Id("__getitem__"), CO . String2Id("co_freevars"), .Arguments)), N), .) ~> ((Locals["__module__"], .Expressions) := ref("globals")(.Arguments)["__name__"]) ~> (if CO . String2Id("co_consts")[0] is not ref("None") : (Locals["__doc__"], .Expressions) := CO . String2Id("co_consts")[0] else: pass) ~> restoreContext(LL, FL, Back) ~> doCall(Metaclass, ListItem(CO . String2Id("co_name")) ListItem(Bases) ListItem(Locals), M) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <frameObject> Back:Int </frameObject>
       <fstack> FL => . </fstack>
       <lstack> LL => . </lstack> [allocation]

 rule <k> restoreContext(LL, FL, N) => . ...</k>
      <fstack> _ => FL </fstack>
      <lstack> _ => LL </lstack>
      <frameObject> _ => N </frameObject>

  rule (processArgs(L:List, M:Map, .Obj, .Obj) => .) ~> invokeClass(_, _, (.Obj => immutable(list(Refify(Idify(L))), ref("tuple"))), (. => stripMetaclass(M)))

  syntax Expression ::= getMetaclass(Arguments) [function]
  rule getMetaclass(X = E:Expression, _) => E when Id2String(X) ==String "metaclass" [function, anywhere]
  rule getMetaclass(Arg, K:K) => getMetaclass(K) when getKLabel Arg =/=KLabel '_=_ [function, anywhere]
  rule getMetaclass(.Expressions) => ref("type") [function, anywhere]

  syntax Map ::= stripMetaclass(Map) [function]
  rule stripMetaclass("metaclass" |-> K M) => stripMetaclass(M) [function, anywhere]
  rule stripMetaclass(S:String |-> K M) => S |-> K stripMetaclass(M) when S=/=String "metaclass" [function, anywhere]
  rule stripMetaclass(.) => . [function, anywhere]

  rule invokeBuiltin(obj("prepare_type",_), _, _) => {.KeyData}

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(O:Object), _) => newHelper(Type, ref("type"), .Set) ~> getref(O, "__class__")
  
  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(O:Object) ListItem(O2:Object), _) => newHelper(Type, ref("type"), .Set) ~> raiseInternal("TypeError", "type() takes 1 or 3 arguments")

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(Name:Object) ListItem(Bases:Object) ListItem(Dict:Object), _) => newHelper(Type, ref("type"), .Set) ~> test(istype(Name, ref("str")), test(istype(Bases, ref("tuple")), test(istype(Dict, ref("dict")), calculateMetaclass(Name, Bases, Type, Dict, Type), raiseInternal("TypeError", "type() argument 3 must be dict")), raiseInternal("TypeError", "type() argument 2 must be tuple")), raiseInternal("TypeError", "type() argument 1 must be str"))

  rule (. => iterate(Bases, .)) ~> calculateMetaclass(_, Bases, _, _, _)
  rule (. => if gettype(O) is ref("type") or bool(hasbase(Winner, gettype(O))) : pass else: test(hasbase(gettype(O), Winner), setWinner(gettype(O)), raiseInternal("TypeError", "metaclass conflict: the metaclass of a derived class must be a (non-strict) subclass of the metaclasses of all its bases"))) ~> list((ListItem(O) => .) _) ~> calculateMetaclass(_, _, _, _, Winner)
  rule (setWinner(O:Object) => .) ~> list(_) ~> calculateMetaclass(_, _, _, _, (_ => O))
  rule list(.) ~> calculateMetaclass(Name, Bases, Type, Dict, Type) => makeType(mutable("__name__" |-> strvalue(Name) "__bases__" |-> ref(id(Bases)), Type), ref("dict")(Dict, .Arguments))
  rule list(.) ~> calculateMetaclass(Name, Bases, Type, Dict, Winner) => Winner . String2Id("__new__") (Winner, Name, Bases, Dict, .Arguments) when Winner =/=K Type

  rule makeType(O:Object, Dict:Object) => (if "__doc__" not in Dict : Dict["__doc__"], .Expressions := ref("None") else: pass) ~> (if "__module__" not in Dict : Dict["__module__"], .Expressions := ref("globals")(.Arguments)["__name__"] else: pass) ~> (if getref(O, "__bases__") == tuple(.Expressions) : setref(id(O), "__bases__", tuple(ref("object"))) else: pass) ~> (if "__hash__" not in Dict and "__eq__" in Dict : Dict["__hash__"], .Expressions := ref("None") else: pass) ~> (if "__new__" in Dict and bool(istype(Dict["__new__"], ref("function"))) : Dict["__new__"], .Expressions := ref("staticmethod")(Dict["__new__"]) else: pass) ~> setref(id(O), "__dict__", Dict) ~> setref(id(O), "__mro__", ref("tuple")(getmember(O, "mro", true, false, true) (.Arguments))) ~> ref(id(O))

endmodule
