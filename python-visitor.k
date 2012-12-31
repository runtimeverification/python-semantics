module PYTHON-VISITOR

  syntax K ::= "visit" "(" K "," KLabel ")"
             | "visited" "(" List{K} ")"
             | "visiting" "(" KLabel "," List{K} "," Int "," KLabel ")"

  syntax KLabel ::= "returner"

  rule visit(Lbl:KLabel(Kl:List{K}), Visitor:KLabel) => visited(.List{K}) ~> visiting(Lbl, Kl, 0, Visitor)
  rule visit(., Visitor:KLabel) => Visitor((KLabel2KLabel(returner)(.List{K})),, -1,, .)
  rule (. => Visitor:KLabel((KLabel2KLabel(Lbl:KLabel)(.List{K})),, N,, K)) ~> visited(_) ~> visiting(Lbl, (K:K,,Kl:List{K} => Kl), (N:Int => N +Int 1), Visitor)
  rule (visited(K) => .) ~> visited(_,,(.List{K} => K))
  rule visited(Kl:List{K}) ~> visiting(Lbl:KLabel, .List{K}, _, Visitor:KLabel) => Visitor((KLabel2KLabel(returner)(.List{K})),, -1,, Lbl(Kl))

endmodule
