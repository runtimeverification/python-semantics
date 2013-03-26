require "python-semantics-syntax.k"

module PYTHON-SEMANTICS-LOGIC
  imports PYTHON-SEMANTICS-SYNTAX

  syntax K ::= K "->" K [strict(1), right]

  syntax K ::= "test" "(" Test "," K "," K ")" [strict(1)]

  syntax K ::= "if" Test ":" K "else" ":" K [strict(1)]
  syntax Expression ::= Expression "if" Test "else" Expression [strict(2)]

  syntax Test ::= "and" "(" Test "," Test ")" [strict(1)]
  syntax Test ::= "or" "(" Test "," Test ")" [strict(1)]
  syntax Test ::= "negate" "(" Test ")" [strict]
  syntax Test ::= Expression "==Obj" Expression [strict]
  syntax Test ::= Expression "=/=Obj" Expression [strict]
  syntax Test ::= "not" Test [strict]
  syntax Test ::= Test "or" Test [strict]
  syntax Test ::= Test "and" Test [strict]

  rule and(false, _) => false
  rule and(_, false) => false
  rule and(true, K) => K
  rule or(true, _) => true
  rule or(_, true) => true
  rule or(false, K) => K
  rule negate(T:Bool) => notBool T
  rule not T:Bool => notBool T
  rule true or _ => true
  rule _ or true => true
  rule false or K => K
  rule false and _ => false
  rule _ and false => false
  rule true and K => K
  rule O:KResult ==Obj O2:KResult => O ==K O2
  rule O:KResult =/=Obj O2:KResult => O =/=K O2

  rule test(true, K:K, _) => K
  rule test(false, _, K) => K
  rule if true : K else: _ => K
  rule if false : _ else: K => K
  rule K if true else _ => K
  rule _ if false else K => K

  rule (O:Object -> _) => O
  rule T:Bool -> _ => T
  rule map(M:Map) -> _ => map(M)
  rule .Obj -> Chain:K => Chain
  rule .Obj (_) => .Obj

  syntax Test ::= Expression "is" "not" "None" [strict]
  syntax Test ::= Expression "is" "None" [strict]
  rule O:Object is not None => not O is None
  rule <k> obj(B,_) is None => B ==K NoneId ...</k>
       <symbols>... "None" |-> NoneId ...</symbols>

  syntax priorities '_|_ > '_isnotNone '_isNone
  syntax priorities '_isnotNone '_isNone > 'not_
endmodule
