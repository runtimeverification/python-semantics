require "python-semantics-syntax.k"

module PYTHON-SEMANTICS-LOGIC
  imports PYTHON-SEMANTICS-SYNTAX

  syntax K ::= K "->" K [strict(1), right]

  //TODO: fix syntax
  syntax K ::= "test" "(" Test "," K "," K ")" [strict(1)]
  syntax Test ::= "and" "(" Test "," Test ")" [strict(1)]
  syntax Test ::= "or" "(" Test "," Test ")" [strict(1)]
  syntax Test ::= "negate" "(" Test ")" [strict]
  syntax Test ::= Exp "==Obj" Exp [strict]
  syntax Test ::= Exp "=/=Obj" Exp [strict]

  syntax Test ::= Test "or" Test [strict(1), left]
  syntax K ::= "if" Test ":" K "else" ":" K [strict(1)]
  syntax Test ::= Exp "is" "None" [strict]

  //TODO: is None / is not None

  rule and(false, _) => false
  rule and(_, false) => false
  rule and(true, K) => K
  rule or(true, _) => true
  rule or(_, true) => true
  rule or(false, K) => K
  rule true or _ => true
  rule _ or true => true
  rule false or K => K
  rule negate(T:Bool) => notBool T
  rule O:KResult ==Obj O2:KResult => O ==K O2
  rule O:KResult =/=Obj O2:KResult => O =/=K O2

  rule test(true, K:K, _) => K
  rule test(false, _, K) => K
  rule if true: K else: _ => K
  rule if false: _ else: K => K

  rule (O:Object -> _) => O
  rule map(M:Map) -> _ => map(M)
  rule .Obj -> Chain:K => Chain
  rule .Obj (_) => .Obj

  rule <k> obj(N,_) is None => N ==K NoneObj ...</k>
       <symbols>... "None" |-> NoneObj ...</symbols>

endmodule
