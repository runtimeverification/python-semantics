module PYTHON-SEMANTICS-CLASSES
  imports PYTHON-SEMANTICS-CALLS

  syntax K ::= "restoreContext" "(" List "," List "," Nat ")"
             | "invokeClass" "(" Expression "," Id "," List "," Map "," Map ")" [strict(1)]

  rule <k> class X:Id ( Args:K ) : Ss:K => bindLocals(Ss, false) ~> String2Id("__module__") := String2Id("__name__") ~> String2Id("__doc__") := docString(Ss) ~> Ss ~> restoreContext(LL, FL, N2) ~> sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeClass(getMetaclass(Args), X, ., ., .) ...</k>
       <nextLoc> N:Nat => N +Int 1 </nextLoc>
       <currentBlock> N2:Nat => N </currentBlock>
       <fstack> FL:List => . </fstack>
       <lstack> LL:List => . </lstack>
       (. => <block>...
         <blockId> N </blockId>
         <parentBlock> N2 </parentBlock>
         <isClass> true </isClass>
       ...</block>)

  rule <k> (restoreContext(LL, FL, N) => .) ~> sortArgs(_) ~> processArgs(_,_,_,_) ~> invokeClass(_, _, _, _, _ => Env) ...</k>
       <currentBlock> N2 => N </currentBlock>
       <fstack> _ => FL </fstack>
       <lstack> _ => LL </lstack>
       <blockId> N2 </blockId>
       <env> Env:Map </env>

  rule (processArgs(L:List, M:Map, .Obj, .Obj) => .) ~> invokeClass(_, _, (. => L), (. => M))

  syntax Expression ::= "getMetaClass" "(" Arguments ")" [function]
  rule getMetaclass(X = E:Expression, _) => E when Id2String(X) ==String "metaclass" [function, anywhere]
  rule getMetaclass(_, K:K) => getMetaclass(K) [function, anywhere]
  rule getMetaclass(.Expressions) => ref("type") [function, anywhere]

  //TODO: use result of __prepare__
  rule invokeClass(O:Object, X, L, M, Env) => doCall(O, ListItem(Id2String(X)) ListItem(immutable(list(Idify(L)), ref("tuple"))) ListItem({DeMapify(Env2Dict(Env))}), stripMetaclass(M))

  syntax Map ::= "stripMetaclass" "(" Map ")" [function]
  rule stripMetaclass("metaclass" |-> K M) => stripMetaclass(M) [function, anywhere]
  rule stripMetaclass(K |-> K2 M) => K |-> K2 stripMetaclass(M) [function, anywhere]

endmodule
