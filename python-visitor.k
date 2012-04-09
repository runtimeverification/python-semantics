module PYTHON-VISITOR

  syntax K ::= "visit" "(" K "," KLabel ")"
             | "visited" "(" List{K} ")"
             | "visiting" "(" KLabel "," List{K} "," #Nat "," KLabel ")"

  declare returner : KLabel -> KLabel

  rule visit(Lbl:KLabel(Kl:List{K}), Visitor:KLabel) => visited(.List{K}) ~> visiting(Lbl, Kl, 0, Visitor)
  rule visit(., Visitor) => returner(Visitor)(.)
  rule (. => Visitor((wklabel Lbl),, N,, K:K)) ~> visited(_) ~> visiting(Lbl, (K,,Kl => Kl), (N:#Nat => sNat(N)), Visitor)
  rule (visited(K) => .) ~> visited(_,,(.List{K} => K))
  rule visited(Kl) ~> visiting(Lbl, .List{K}, _, Visitor) => returner(Visitor)(Lbl(Kl))

end module
