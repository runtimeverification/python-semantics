module PYTHON-SEMANTICS-LOGIC
  imports PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax K ::= K "->" K [:strict(1) gather(e E) prec 42:]

  syntax ObjRef ::= "test" "(" Test "," K "," K ")" [:strict(1):]

  syntax Test ::= "and" "(" Test "," Test ")" [:strict(1):]
  syntax Test ::= "or" "(" Test "," Test ")" [:strict(1):]
  syntax Test ::= "negate" "(" Test ")" [:strict:]
  syntax Test ::= "equals" "(" Test "," Test ")" [:strict:]

  rule and(false, _) => false
  rule and(_, false) => false
  rule and(true, K) => K
  rule or(true, _) => true
  rule or(_, true) => true
  rule or(false, K) => K
  rule negate(T:Bool) => notBool T
  rule equals(K, K2:K) => K ==K K2

  rule test(true, K:K, _) => K
  rule test(false, _, K) => K

  rule (O:Object -> _) => O
  rule .Obj -> Chain:K => Chain
  rule .Obj (_) => .Obj

end module
