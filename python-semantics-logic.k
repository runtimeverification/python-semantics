module PYTHON-SEMANTICS-LOGIC
  imports PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax K ::= K "->" K [:strict(1) gather(e E):]

  syntax ObjRef ::= "test" "(" Test "," K "," K ")" [:strict(1):]

  declare and : Test Test -> Test
  declare or : Test Test -> Test
  declare negate : Test -> Test
  declare equals : Expression Expression -> Test

  context and(HOLE,_)
  context or(HOLE,_)
  context negate(HOLE)
  context equals(HOLE,_)
  context equals(_,HOLE)

  define and(false, _) => false
  define and(_, false) => false
  define and(true, K) => K
  define or(true, _) => true
  define or(_, true) => true
  define or(false, K) => K
  define negate(T:#Bool) => notBool T
  define equals(K, K2:K) => K ==Bool K2

  rule test(true, K:K, _) => K
  rule test(false, _, K) => K

  rule (O:Object -> _) => O
  rule .Obj -> Chain:K => Chain
  rule .Obj (_) => .Obj

end module
