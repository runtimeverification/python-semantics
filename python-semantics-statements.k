require "python-semantics-boolean-ops.k"
require "python-semantics-try.k"

module PYTHON-SEMANTICS-STATEMENTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS
  imports PYTHON-SEMANTICS-TRY

  syntax K ::= "lmark"

  syntax ListItem ::= "(" K "," K "," Bag ")"

  rule global _ => .
  rule nonlocal _ => .

  rule if O:Object : Ss:K else : Ss2:K => test(plbool(bool(O)), Ss, Ss2)
  rule E:K if O else E2:K => test(plbool(bool(O)), E, E2)

  rule <k> (. => lmark) ~> (while Condition:K : Ss else: Ss2) ~> (K:K => break) </k>
       <control>
         <lstack> . => (K, while Condition : Ss else: Ss2, C) ...</lstack>
         C:Bag
       </control>

  rule lmark ~> while Condition : Ss else: Ss2 => if Condition : (Ss ~> lmark ~> while Condition : Ss else: Ss2) else: Ss2

  rule [terminate-loop]: <k> break ~> _ => K </k>
       <control>
         <lstack> (K, _, C) => . ...</lstack>
         (_ => C)
       </control>

  rule <k> (. => Finally:K) ~> break ...</k>
       <control>
         <lstack> (Finally, C, XL:List, _, FL:List, Ex:K) => . ...</lstack>
         <xstack> _ => XL </xstack>
         <xcontext> _ => Ex </xcontext>
         <fstack> _ => FL </fstack>
         (_ => C)
       </control>

  rule <k> continue => lmark ~> K ~> break ...</k>
       <lstack> (_, K, _:Bag) ...</lstack>

  rule <k> (. => Finally) ~> continue ...</k>
       <control>
         <lstack> (Finally, C, XL, _, FL, Ex) => . ...</lstack>
         <xstack> _ => XL </xstack>
         <xcontext> _ => Ex </xcontext>
         <fstack> _ => FL </fstack>
         (_ => C)
       </control>

  context for _ in (HOLE => ref("iter") (HOLE, .Arguments)) : _ else: _

  rule [mark-for]: <k> (. => lmark) ~> (for Targets:K in O : Ss else: Ss2) ~> (K => break) </k>
       <control>
         <lstack> . => (K, for Targets in O : Ss else: Ss2, C) ...</lstack>
         C:Bag
       </control>

  rule [unroll-for]: lmark ~> for Targets in O : Ss else: Ss2 => try: (((Targets, .Expressions) := getmember(O, "__next__", true, false, true) (.Arguments)) ~> Ss ~> lmark ~> for Targets in O : Ss else: Ss2) except ref("StopIteration"): Ss2 else: .

  rule O:Object ; => .

  rule Stmt:K newline Ss => Stmt ~> Ss

  rule with O:Object : Ss => doWith(O . String2Id("__exit__"), O . String2Id("__enter__") (.Arguments), ., Ss)
  rule with O:Object as T:Target : Ss => doWith(O . String2Id("__exit__"), O . String2Id("__enter__") (.Arguments), T, Ss)
  
  syntax K ::= doWith(Expression, Expression, K, K) [seqstrict(1, 2)]

  // we copy from python-semantics-try.k so we can reuse finally functionality and still choose whether we suppress a raised exception
  rule <k> (doWith(Exit:Object, Enter:Object, T, Ss) => #if T ==K . #then . #else T, .Expressions := Enter #fi ~> Ss ~> popfinally ~> Exit(* ref("sys_exc_info")(.Arguments)) ;) ~> K </k>
       <control>
         <xstack> (. => (if not Exit(* ref("sys_exc_info")(.Arguments)): raise else: (setx(Ex) ~> K), C, XL, LL, FL, Ex)) XL:List </xstack> 
         <lstack> (. => (Exit(* ref("sys_exc_info")(.Arguments)) ;, C, XL, LL, FL, Ex)) LL:List </lstack>
         <fstack> (. => (Exit(* ref("sys_exc_info")(.Arguments)) ;, C, XL, LL, FL, Ex)) FL:List </fstack>
         <xcontext> Ex </xcontext>
         C:Bag
       </control>

endmodule
