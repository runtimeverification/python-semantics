require "python-semantics-boolean-ops.k"
require "python-semantics-try.k"

module PYTHON-SEMANTICS-STATEMENTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS
  imports PYTHON-SEMANTICS-TRY

  syntax K ::= "lmark"

  syntax K ::= loop(K, K, CurrentFrameCellFragment)

  rule global _ => .
  rule nonlocal _ => .

  rule if O:Object : Ss:K else : Ss2:K => test(plbool(bool(O)), Ss, Ss2)
  rule E:K if O else E2:K => test(plbool(bool(O)), E, E2)

  rule <k> (. => lmark) ~> (while Condition:K : Ss else: Ss2) ~> (K:K => break) </k>
       <currentFrame>
         <lstack> . => ListItem(loop(K, while Condition : Ss else: Ss2, C)) ...</lstack>
         C:Bag
       </currentFrame>

  rule lmark ~> while Condition : Ss else: Ss2 => if Condition : (Ss ~> lmark ~> while Condition : Ss else: Ss2) else: Ss2

  rule [terminate-loop]: <k> break ~> _ => K </k>
       <currentFrame>
         <lstack> ListItem(loop(K, _, C)) => . ...</lstack>
         (_ => C)
       </currentFrame>

  rule <k> (. => Finally:K) ~> break ...</k>
       <currentFrame>
         <lstack> ListItem(finally(Finally, C, XL:List, _, FL:List, Ex)) => . ...</lstack>
         <xstack> _ => XL </xstack>
         <fstack> _ => FL </fstack>
         <xcontext> _ => Ex </xcontext>
         (_ => C)
       </currentFrame>

  rule <k> continue => lmark ~> K ~> break ...</k>
       <lstack> ListItem(loop(_, K, _:Bag)) ...</lstack>

  rule <k> (. => Finally) ~> continue ...</k>
       <currentFrame>
         <lstack> ListItem(finally(Finally, C, XL:List, _, FL:List, Ex)) => . ...</lstack>
         <xstack> _ => XL </xstack>
         <fstack> _ => FL </fstack>
         <xcontext> _ => Ex </xcontext>
         (_ => C)
       </currentFrame>

  rule for T in E : S1 else: S2 => ref("iter") (E ::Exp) ~> (for T in HOLE : S1 else: S2) [heat]
  rule O:Object ~> (for T in HOLE : S1 else: S2) => for T in O : S1 else: S2 [cool]

  rule [mark-for]: <k> (. => lmark) ~> (for Targets:K in O:Object : Ss else: Ss2) ~> (K => break) </k>
       <currentFrame>
         <lstack> . => ListItem(loop(K, for Targets in O : Ss else: Ss2, C)) ...</lstack>
         C:Bag
       </currentFrame>

  rule [unroll-for]: lmark ~> for Target:Target in O : Ss else: Ss2 => try: (((Target) = getmember(O, "__next__", true, false, true) (.Arguments)) ~> Ss ~> lmark ~> for Target in O : Ss else: Ss2) except ref("StopIteration"): Ss2 else: .

  rule O:Object ; => .

  rule Stmt:K newline Ss => Stmt ~> Ss when Ss =/=K .Stmts
  rule Stmt:K newline .Stmts => Stmt [macro]

  rule with O:Object : Ss => doWith(O . String2Id("__exit__"), O . String2Id("__enter__") (.Arguments), ., Ss)
  rule with O:Object as T:Exp : Ss => doWith(O . String2Id("__exit__"), O . String2Id("__enter__") (.Arguments), T, Ss)
  
  syntax K ::= doWith(Exp, Exp, K, K) [seqstrict(1, 2)]

  rule isKResult(O:KResult as _) => true

  // we copy from python-semantics-try.k so we can reuse finally functionality and still choose whether we suppress a raised exception
  rule <k> (doWith(Exit:Object, Enter:Object, T, Ss) => #if T ==K . #then . #else T ::Target = Enter #fi ~> Ss ~> popfinally ~> Exit(* ref("sys_exc_info")(.Arguments)) ;) ~> K </k>
       <currentFrame>
         <xstack> (. => ListItem(finally(if not Exit(* ref("sys_exc_info")(.Arguments)): raise else: (setx(Ex) ~> K), C, XL, LL, FL, Ex))) XL:List </xstack> 
         <lstack> (. => ListItem(finally(Exit(* ref("sys_exc_info")(.Arguments)) ;, C, XL, LL, FL, Ex))) LL:List </lstack>
         <fstack> (. => ListItem(finally(Exit(* ref("sys_exc_info")(.Arguments)) ;, C, XL, LL, FL, Ex))) FL:List </fstack>
         <xcontext> Ex </xcontext>
         C:Bag
       </currentFrame>

endmodule
