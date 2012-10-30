require "python-semantics-calls.k"

module PYTHON-SEMANTICS-CLASSES
  imports PYTHON-SEMANTICS-CALLS

  syntax ObjRef ::= makeType(Expression, Expression) [strict]
                  | invokeClass(Expression, Expression, Expression, Map) [strict(1 2 3)]
                  | executeClass(Expression, Expression, Expression, Expression, Expression, Expression) [strict] 
                  | calculateMetaclass(Expression, Expression, Expression, Expression, Expression) [strict]

  syntax K ::= restoreContext(List, List, Int)
             | setWinner(Expression) [strict]
  rule class(Args, CO:Object) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeClass(getMetaclass(Args), CO, .Obj, .)

  rule invokeClass(Metaclass:Object, CO:Object, Bases:Object, M:Map) => executeClass(Metaclass, CO, Bases, ref("builtins"), ref("globals")(.Arguments), doCall(Metaclass . String2Id("__prepare__"), ListItem(CO . String2Id("co_name")) ListItem(Bases), M))

   rule <k> executeClass(Metaclass:Object, CO:Object, Bases:Object, Builtins:Object, Globals:Object, Locals:Object) => executeFrame(N, CO, ref(Back), Locals, Globals, Builtins, makeCells(CO . String2Id("co_freevars"), CO . String2Id("co_cellvars"), ref("tuple")(ref("map")(getref2(ref(Back), "f_cells") . String2Id("__getitem__"), CO . String2Id("co_freevars"), .Arguments)), N), .) ~>  (String2Id("__module__"), .Expressions) := ref("globals")(.Arguments)["__name__"] ~> if CO . String2Id("co_consts")[0] is not ref("None") : (String2Id("__doc__"), .Expressions) := CO . String2Id("co_consts")[0] else: pass ~> restoreContext(LL, FL, Back) ~> doCall(Metaclass, ListItem(Metaclass) ListItem(CO . String2Id("co_name")) ListItem(Bases) ListItem(Locals), .) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <currentFrame> Back:Int </currentFrame>
       <fstack> FL => . </fstack>
       <lstack> LL => . </lstack>

 rule <k> restoreContext(LL, FL, N) => . ...</k>
      <fstack> _ => FL </fstack>
      <lstack> _ => LL </lstack>
      <currentFrame> _ => N </currentFrame>

  rule (processArgs(L:List, M:Map, .Obj, .Obj) => .) ~> invokeClass(_, _, (.Obj => immutable(list(Idify(L)), ref("tuple"))), (. => stripMetaclass(M)))

  syntax Expression ::= getMetaclass(Arguments) [function]
  rule getMetaclass(X = E:Expression, _) => E when Id2String(X) ==String "metaclass" [function, anywhere]
  rule getMetaclass(_, K:K) => getMetaclass(K) [function, anywhere]
  rule getMetaclass(.Expressions) => ref("type") [function, anywhere]

  syntax Map ::= stripMetaclass(Map) [function]
  rule stripMetaclass("metaclass" |-> K M) => stripMetaclass(M) [function, anywhere]
  rule stripMetaclass(K |-> K2 M) => K |-> K2 stripMetaclass(M) [function, anywhere]
  rule stripMetaclass(.) => . [function, anywhere]

  rule invokeBuiltin(obj("prepare_type",_), _, _) => {.KeyData}

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(O:Object), .) => newHelper(Type, ref("type"), .Set) ~> getref(O, "__class__")
  
  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(O:Object) ListItem(O2:Object), .) => newHelper(Type, ref("type"), .Set) ~> raiseInternal("TypeError", "type() takes 1 or 3 arguments")

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(Name:Object) ListItem(Bases:Object) ListItem(Dict:Object), .) => newHelper(Type, ref("type"), .Set) ~> test(istype(Name, ref("str")), test(istype(Bases, ref("tuple")), test(istype(Dict, ref("dict")), calculateMetaclass(Name, Bases, Type, Dict, Type), raiseInternal("TypeError", "type() argument 3 must be dict")), raiseInternal("TypeError", "type() argument 2 must be tuple")), raiseInternal("TypeError", "type() argument 1 must be str"))

  rule (. => iterate(Bases, .)) ~> calculateMetaclass(_, Bases, _, _, _)
  rule (. => if gettype(O) is ref("type") or bool(hasbase(Winner, gettype(O))) : pass else: test(hasbase(gettype(O), Winner), setWinner(gettype(O)), raiseInternal("TypeError", "metaclass conflict: the metaclass of a derived class must be a (non-strict) subclass of the metaclasses of all its bases"))) ~> list((ListItem(O) => .) _) ~> calculateMetaclass(_, _, _, _, Winner)
  rule (setWinner(O:Object) => .) ~> list(_) ~> calculateMetaclass(_, _, _, _, (_ => O))
  rule list(.) ~> calculateMetaclass(Name, Bases, Type, Dict, Type) => makeType(mutable("__name__" |-> strvalue(Name) "__bases__" |-> id(Bases), Type), ref("dict")(Dict))
  rule list(.) ~> calculateMetaclass(Name, Bases, Type, Dict, Winner) => Winner . String2Id("__new__") (Winner, Name, Bases, Dict) when Winner =/=K Type

  rule makeType(O:Object, Dict:Object) => (if "__doc__" not in Dict : Dict["__doc__"], .Expressions := ref("None") else: pass) ~> (if "__module__" not in Dict : Dict["__module__"], .Expressions := ref("globals")(.Arguments)["__name__"] else: pass) ~> (if getref(O, "__bases__") == tuple(.Expressions) : setref(id(O), "__bases__", tuple(ref("object"))) else: pass) ~> setref(id(O), "__dict__", Dict) ~> setref(id(O), "__mro__", ref("tuple")(getmember(O, "mro", true, false, true) (.Arguments))) ~> ref(id(O))

endmodule
