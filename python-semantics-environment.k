module PYTHON-SEMANTICS-ENVIRONMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "envLookup" "(" #Id "," #Int ")"

  rule <k> builtin(X:#Id) => _._(ref(Env(#id "__builtins__")) , X) ...</k>
       <blockId> 0 </blockId>
       <env> Env:Map </env>

  macro bind(X, B) = doBind(X, B, true)
  macro unbind(X) = doBind(X, 0, false)

  rule <k> X => envLookup(X,N:#Nat) ...</k>
       <currentBlock> N </currentBlock>

  rule <k> envLookup(X,N) => ref(N2) ...</k>
       <blockId> N </blockId>
       <env>... X |-> N2:#Nat ...</env> when N2 =/=Bool 0

  rule <k> envLookup(X,N) => raiseInternal("UnboundLocalError","local variable '" +String Id2String(X) +String "' referenced before assignment") ...</k>
       <blockId> N </blockId>
       <env>... X |-> 0 ...</env>

  rule <k> envLookup(X,(N => N2)) ...</k>
       <blockId> N </blockId>
       <parentBlock> N2 </parentBlock>
       <globals> S:Set </globals>
       <env> Env </env> when notBool(X in keys(Env)) andBool notBool(X in S) andBool N =/=Bool 0

  rule <k> envLookup(X,(N => 0)) ...</k>
       <blockId> N </blockId>
       <globals> S:Set </globals>
       <env> Env </env> when X in S andBool N =/=Bool 0

  rule <k> envLookup(X,0) => builtin(X) ...</k>
       <blockId> 0 </blockId>
       <env> Env #id "__builtins__" |-> N </env>
       <object>...
         <id>N</id>
         <oenv> OEnv:Map </oenv>
       ...</object> when notBool(X in keys(Env)) andBool (Id2String(X) in keys(OEnv))

  rule <k> envLookup(X,0) => raiseInternal("NameError", "name '" +String Id2String(X) +String "' is not defined") ...</k>
       <blockId> 0 </blockId>
       <env> Env #id "__builtins__" |-> N </env>
       <object>...
         <id>N</id>
         <oenv> OEnv:Map </oenv>
       ...</object> when notBool(X in keys(Env)) andBool notBool(Id2String(X) in keys(OEnv))

  rule <k> doBind(X, B:Builtin, T:#Bool) => . ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <globals> S1:Set </globals>
       <nonlocals> S2:Set </nonlocals>
       <env> Env => if T then Env[B / X] else Env[undef/X] fi </env> when notBool(X in S1 orBool X in S2)

  rule <k> doBind(X, B, T) => . ...</k>
       <currentBlock> N </currentBlock>
       <block>...
         <blockId> N </blockId>
         <globals>... SetItem(X) ...</globals>
       ...</block>
       <block>...
         <blockId> 0 </blockId>
         <env> Env => if T then Env[B / X] else Env[undef/X] fi </env>
       ...</block>

  rule <k> doBind(X, B, T) => doNonlocalBind(X, B, N2, T) ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <parentBlock> N2 </parentBlock>
       <nonlocals>... SetItem(X) ...</nonlocals>

  rule <k> doNonlocalBind(X, B, N, T) => . ...</k>
       <blockId> N </blockId>
       <env> Env => if T then Env[B / X] else Env[undef/X] fi</env> when X in keys(Env)

  rule <k> doNonlocalBind(X, B, N, T) => doNonlocalBind(X, B, N2, T) ...</k>
       <blockId> N </blockId>
       <parentBlock> N2 </parentBlock>
       <env> Env </env> when notBool(X in keys(Env))

  //TODO: SyntaxErrors for top-level nonlocals, unbound nonlocals, simultaneous global and nonlocal

  rule <currentBlock> N </currentBlock>
       (<block>...
         <blockId> N2 </blockId>
         <parentBlock> N </parentBlock>
       ...</block> => .) [:structural:]

end module
