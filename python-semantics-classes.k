require "python-semantics-calls.k"

module PYTHON-SEMANTICS-CLASSES
  imports PYTHON-SEMANTICS-CALLS

  rule class(Args, CO:Object) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeClass(getMetaclass(Args), CO, .Obj, .)

  rule invokeClass(Metaclass:Object, CO:Object, Bases:Object, M:Map) => executeClass(Metaclass, CO, Bases, ref("builtins"), ref("globals")(.Arguments), doCall(getmember(Metaclass, String2Id("__prepare__"), false, true, true), ListItem(CO . String2Id("co_name")) ListItem(Bases), M))

   rule <k> executeClass(Metaclass:Object, CO:Object, Bases:Object, Builtins:Object, Globals:Object, Locals:Object) => executeFrame(N, CO, ref(Back), Locals, Globals, Builtins, makeCells(CO . String2Id("co_freevars"), CO . String2Id("co_cellvars"), getref2(ref(Back), "f_cells"), N), .) ~>  (String2Id("__module__"), .Expressions) := ref("globals")(String2Id("__name__")) ~> restoreContext(LL, FL, Back) ~> doCall(getmember(Metaclass. String2Id("__new__"), false, true, true), ListItem(Metaclass) ListItem(CO . String2Id("co_name")) ListItem(Bases) ListItem(Locals), .) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <currentFrame> Back:Int </currentFrame>
       <fstack> FL => . </fstack>
       <lstack> LL => . </lstack>

 rule <k> restoreContext(LL, FL, N) => . ...</k>
      <fstack> _ => FL </fstack>
      <lstack> _ => LL </lstack>
      <currentFrame> _ => N </currentFrame>

  rule (processArgs(L:List, M:Map, .Obj, .Obj) => .) ~> invokeClass(_, _, (.Obj => immutable(list(Idify(L)), ref("tuple"))), (. => stripMetaclass(M)))

  syntax Expression ::= "getMetaClass" "(" Arguments ")" [function]
  rule getMetaclass(X = E:Expression, _) => E when Id2String(X) ==String "metaclass" [function, anywhere]
  rule getMetaclass(_, K:K) => getMetaclass(K) [function, anywhere]
  rule getMetaclass(.Expressions) => ref("type") [function, anywhere]

  syntax Map ::= "stripMetaclass" "(" Map ")" [function]
  rule stripMetaclass("metaclass" |-> K M) => stripMetaclass(M) [function, anywhere]
  rule stripMetaclass(K |-> K2 M) => K |-> K2 stripMetaclass(M) [function, anywhere]

  rule invokeBuiltin(obj("new_type",_), ListItem(Type:Object) ListItem(Name:Object) ListItem(Bases:Object) ListItem(Dict:Object), .)

endmodule
