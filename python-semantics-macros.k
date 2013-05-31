require "python-semantics-common.k"

module PYTHON-SEMANTICS-MACROS
  imports PYTHON-SEMANTICS-COMMON

  syntax #Id ::= "__debug__"
  syntax #Id ::= "AssertionError"

  rule pass => .K [macro]

  rule assert E => if __debug__ : if not E : raise AssertionError [macro]
  rule assert E , E2 => if __debug__ : if not E : raise AssertionError(E2 ::Exp) [macro]

  rule if E ::Exp : S => if E : S else : .K [macro]

  rule return => return ref("None") [macro]
  rule yield => yield ref("None") [macro]

  rule : : => (ref("slice") (ref("None"), ref("None"), ref("None"))) [macro]
  rule E : : => (ref("slice") (E ::Exp, ref("None"), ref("None"))) [macro]
  rule : E : => (ref("slice") (ref("None"), E ::Exp, ref("None"))) [macro]
  rule : : E => (ref("slice") (ref("None"), ref("None"), E ::Exp)) [macro]
  rule E : E2 : => (ref("slice") (E ::Exp, E2 ::Exp, ref("None"))) [macro]
  rule E : : E2 => (ref("slice") (E ::Exp, ref("None"), E2 ::Exp)) [macro]
  rule : E : E2 => (ref("slice") (ref("None"), E ::Exp, E ::Exp)) [macro]
  rule E : E2 : E3 => (ref("slice") (E ::Exp, E2 ::Exp, E3 ::Exp)) [macro]

  syntax Id ::= "declName" "(" K ")" [function]
  rule declName(def X:Id ( _ ) -> _ : _) => X 
  rule declName(def X ( _ ) : _) => X 
  rule declName(class X ( _ ) : _) => X 
  rule declName(K ; _) => declName(K) 

  rule @ K ::Exp _:NEWLINE K2:K => K2 ?Newline:NEWLINE declName(K2) = K(declName(K2)) [macro]

  rule try: Try ExceptClauses else: Else finally: Finally => try: try: Try ExceptClauses else: Else finally: Finally [macro]
  rule try: Try ExceptClauses => try: Try ExceptClauses else: .K [macro]

  rule with W, W2, W3 : Body => with W ::Alias : with W2, W3 : Body [macro]

  rule [ E Comp ] => ref("list")(generator(E Comp)) [macro]
  rule { E Comp } => ref("set")(generator(E Comp)) [macro]
  rule { E : E2 Comp } => ref("dict")(generator(tuple(E ::Exp, E2 ::Exp) Comp)) [macro]

endmodule
