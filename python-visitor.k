module PYTHON-VISITOR

  syntax K ::= "visit" "(" K "," KLabel ")"
             | "visited" "(" KList ")"
             | "visiting" "(" KLabel "," KList "," Int "," KLabel ")"

  syntax KLabel ::= "returner"

  rule visit(Lbl:KLabel(Kl:KList), Visitor:KLabel) => visited(.KList) ~> visiting(Lbl, Kl, 0, Visitor)
  rule visit(., Visitor:KLabel) => Visitor((KLabel2KLabel(returner)(.KList)),, -1,, .)
  rule (. => Visitor:KLabel((KLabel2KLabel(Lbl:KLabel)(.KList)),, N,, K)) ~> visited(_) ~> visiting(Lbl, (K:K,,Kl:KList => Kl), (N:Int => N +Int 1), Visitor)
  rule (visited(K) => .) ~> visited(_,,(.KList => K))
  rule visited(Kl:KList) ~> visiting(Lbl:KLabel, .KList, _, Visitor:KLabel) => Visitor((KLabel2KLabel(returner)(.KList)),, -1,, Lbl(Kl))

endmodule
