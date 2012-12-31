require "python-semantics-common.k"

module PYTHON-SEMANTICS-MACROS
  imports PYTHON-SEMANTICS-COMMON

  rule assert E:K , Es:K => if String2Id("__debug__") :
                                               (if not E :
                                                  raise String2Id("AssertionError") (Es)
                                                else: pass)
                                              else: pass [macro, anywhere]
  rule pass => .K [macro, anywhere]

  rule return => return ref("None") [macro, anywhere]
  rule yield => yield ref("None") [macro, anywhere]

  rule : : => (ref("slice") (ref("None"), ref("None"), ref("None"), .Expressions)) [macro, anywhere]
  rule E : : => (ref("slice") (E, ref("None"), ref("None"), .Expressions)) [macro, anywhere]
  rule : E : => (ref("slice") (ref("None"), E, ref("None"), .Expressions)) [macro, anywhere]
  rule : : E => (ref("slice") (ref("None"), ref("None"), E, .Expressions)) [macro, anywhere]
  rule E : E2:Expression : => (ref("slice") (E, E2, ref("None"), .Expressions)) [macro, anywhere]
  rule E : : E2 => (ref("slice") (E, ref("None"), E2, .Expressions)) [macro, anywhere]
  rule : E : E2 => (ref("slice") (ref("None"), E, E, .Expressions)) [macro, anywhere]
  rule E : E2 : E3:Expression => (ref("slice") (E, E2, E3, .Expressions)) [macro, anywhere]

  syntax Id ::= "declName" "(" K ")" [function]
  rule declName(def X:Id ( _ ) -> _ : _) => X [function, anywhere]
  rule declName(def X ( _ ) : _) => X [function, anywhere]
  rule declName(class X ( _ ) : _) => X [function, anywhere]
  rule declName(K newline _) => declName(K) [function, anywhere]

  rule @ K:K newline K2:K => K2 newline declName(K2) , .Expressions := K(declName(K2)) [macro, anywhere]

  rule try: Try ExceptClauses else: Else finally: Finally => try: try: Try ExceptClauses else: Else finally: Finally [macro, anywhere]

  rule with W, W2, W3 : Body => with W, .Aliases : with W2, W3: Body [macro, anywhere]

  rule [ E Comp ] => ref("list")(generator(E Comp)) [macro, anywhere]
  rule { E Comp } => ref("set")(generator(E Comp)) [macro, anywhere]
  rule { E : E2 Comp } => ref("dict")(generator(tuple(E, E2) Comp)) [macro, anywhere]

endmodule
