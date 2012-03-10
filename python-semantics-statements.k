module PYTHON-SEMANTICS-STATEMENTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax K ::= "lmark"
             | "popl"

  syntax ListItem ::= "(" K "," K "," Bag ")"

  rule global _ => .
  rule nonlocal _ => .

  rule if O:Object : Ss:K else : Ss2:K => test(plbool(bool(O)), Ss, Ss2)

  rule <k> (. => lmark) ~> while Condition:K : Ss else: Ss2 ~> (K:K => popl) </k>
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
         <lstack> (Finally, C, X:List, _, Ex:K) => . ...</lstack>
         <xstack> _ => X </xstack>
         <xcontext> _ => Ex </xcontext>
         (_ => C)
       </control>

  rule break => popl

  rule <k> continue => lmark ~> K ~> popl ...</k>
       <lstack> (_, K, _:Bag) ...</lstack>

  rule <k> (. => Finally) ~> continue ...</k>
       <control>
         <lstack> (Finally, C, X, _, Ex) => . ...</lstack>
         <xstack> _ => X </xstack>
         <xcontext> _ => Ex </xcontext>
         (_ => C)
       </control>

  context for _ in (HOLE => ref("iter") (HOLE, .List{","})) : _ else: _

  rule <k> (. => lmark) ~> for Targets:K in O : Ss else: Ss2 ~> (K => popl) </k>
       <control>
         <lstack> . => (K, for Targets in O : Ss else: Ss2, C) ...</lstack>
         C:Bag
       </control>

  rule lmark ~> for Targets in O : Ss else: Ss2 => try: ((Targets, .Expressions) := getmember(O, #id "__next__", true, false, true) () ~> Ss ~> lmark ~> for Targets in O : Ss else: Ss2) except ref("StopIteration"): Ss2 else: .

  rule O ; => .

  rule Stmt:K newline Ss => Stmt ~> Ss

end module
