require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-STATEMENTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax K ::= "lmark"
             | "popl"

  syntax ListItem ::= "(" K "," K "," Bag ")"

  rule global _ => .
  rule nonlocal _ => .

  rule if O:Object : Ss:K else : Ss2:K => test(plbool(bool(O)), Ss, Ss2)
  rule E:K if O else E2:K => test(plbool(bool(O)), E, E2)

  rule <k> (. => lmark) ~> (while Condition:K : Ss else: Ss2) ~> (K:K => popl) </k>
       <control>
         <lstack> . => (K, while Condition : Ss else: Ss2, C) ...</lstack>
         C:Bag
       </control>

  rule lmark ~> while Condition : Ss else: Ss2 => if Condition : (Ss ~> lmark ~> while Condition : Ss else: Ss2) else: Ss2

  rule <k> popl ~> _ => K </k>
       <control>
         <lstack> (K, _, C) => . ...</lstack>
         (_ => C)
       </control>

  rule <k> (. => Finally:K) ~> popl ...</k>
       <control>
         <lstack> (Finally, C, XL:List, _, FL:List, Ex:K) => . ...</lstack>
         <xstack> _ => XL </xstack>
         <xcontext> _ => Ex </xcontext>
         <fstack> _ => FL </fstack>
         (_ => C)
       </control>

  rule break => popl

  rule <k> continue => lmark ~> K ~> popl ...</k>
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

  rule <k> (. => lmark) ~> (for Targets:K in O : Ss else: Ss2) ~> (K => popl) </k>
       <control>
         <lstack> . => (K, for Targets in O : Ss else: Ss2, C) ...</lstack>
         C:Bag
       </control>

  rule lmark ~> for Targets in O : Ss else: Ss2 => try: (((Targets, .Expressions) := getmember(O, "__next__", true, false, true) (.Arguments)) ~> Ss ~> lmark ~> for Targets in O : Ss else: Ss2) except ref("StopIteration"): Ss2 else: .

  rule O:Object ; => .

  rule Stmt:K newline Ss => Stmt ~> Ss

endmodule
