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

  //TODO: is None / is not None

  rule and(false, _) => false
  rule and(_, false) => false
  rule and(true, K) => K
  rule or(true, _) => true
  rule or(_, true) => true
  rule or(false, K) => K
  rule negate(T:Bool) => notBool T
  rule O:KResult ==Obj O2:KResult => O ==K O2
  rule O:KResult =/=Obj O2:KResult => O =/=K O2

  rule test(true, K:K, _) => K
  rule test(false, _, K) => K

  rule (O:Object -> _) => O
  rule map(M:Map) -> _ => map(M)
  rule .Obj -> Chain:K => Chain
  rule .Obj (_) => .Obj

endmodule
