module PYTHON-VISITOR

  syntax K ::= "visit" "(" K "," KLabel ")"
             | "visited" "(" List{K} ")"
             | "visiting" "(" KLabel "," List{K} "," Nat "," KLabel ")"

  syntax KLabel ::= "returner" "(" KLabel ")" [:function:]

  rule visit(Lbl:KLabel(Kl:List{K}), Visitor:KLabel) => visited(.List{K}) ~> visiting(Lbl, Kl, 0, Visitor)
  rule visit(., Visitor) => returner(Visitor)(.)
  rule (. => Visitor((KLabel2K Lbl),, N,, K:K)) ~> visited(_) ~> visiting(Lbl, (K,,Kl => Kl), (N:Nat => N +Int 1), Visitor)
  rule (visited(K) => .) ~> visited(_,,(.List{K} => K))
  rule visited(Kl) ~> visiting(Lbl, .List{K}, _, Visitor) => returner(Visitor)(Lbl(Kl))

end module
