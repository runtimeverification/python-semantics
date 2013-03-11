require "python-semantics-common.k"

module PYTHON-SEMANTICS-MACROS
  imports PYTHON-SEMANTICS-COMMON

  syntax #Id ::= "__debug__"
  syntax #Id ::= "AssertionError"

  rule pass => .K [macro]

  rule assert E:Exp => if __debug__: if not E: raise AssertionError [macro]
  rule assert E:Exp , E2:Exp => if __debug__: if not E: raise AssertionError(E2) [macro]

  rule if E:Exp : S => if E: S else: pass [macro]

  rule return => return ref("None") [macro]
  rule yield => yield ref("None") [macro]

  rule : : => (ref("slice") (ref("None"), ref("None"), ref("None"))) [macro]
  rule E:Exp : : => (ref("slice") (E, ref("None"), ref("None"))) [macro]
  rule : E:Exp : => (ref("slice") (ref("None"), E, ref("None"))) [macro]
  rule : : E:Exp => (ref("slice") (ref("None"), ref("None"), E)) [macro]
  rule E:Exp : E2:Exp : => (ref("slice") (E, E2, ref("None"))) [macro]
  rule E:Exp : : E2:Exp => (ref("slice") (E, ref("None"), E2)) [macro]
  rule : E:Exp : E2:Exp => (ref("slice") (ref("None"), E, E)) [macro]
  rule E:Exp : E2:Exp : E3:Exp => (ref("slice") (E, E2, E3)) [macro]

  syntax Id ::= "declName" "(" K ")" [function]
  rule declName(def X:Id ( _ ) -> _ : _) => X 
  rule declName(def X ( _ ) : _) => X 
  rule declName(class X ( _ ) : _) => X 
  rule declName(K newline _) => declName(K) 

  rule @ K:Exp K2:K => K2 newline declName(K2) = K(declName(K2)) [macro]

  rule try: Try ExceptClauses else: Else finally: Finally => try: try: Try ExceptClauses else: Else finally: Finally [macro]

  rule with W, W2, W3 : Body => with W, .Aliases : with W2, W3: Body [macro]

  rule [ E Comp ] => ref("list")(generator(E Comp)) [macro]
  rule { E Comp } => ref("set")(generator(E Comp)) [macro]
  rule { E : E2 Comp } => ref("dict")(generator(tuple(E, E2) Comp)) [macro]

endmodule
