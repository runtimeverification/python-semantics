require "python-semantics-common.k"

module PYTHON-SEMANTICS-AUGMENTED-ASSIGNMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "augAssign" "(" Target "," Object "," KLabel "," Expression ")"
  syntax K ::= "augAssign2" "(" Target "," Expression "," Object "," KLabel "," Id ")" [strict(2)]

  rule T:Target += O:Object => augAssign(T, O, '_+_ , "__iadd__")
  rule T -= O:Object => augAssign(T, O, '_-_ , "__isub__")
  rule T *= O:Object => augAssign(T, O, '_*_ , "__imul__")
  rule T /= O:Object => augAssign(T, O, '_/_ , "__itruediv__")
  rule T floor/= O:Object => augAssign(T, O, '_floor/_ , "__ifloordiv__")
  rule T %= O:Object => augAssign(T, O, '_%_ , "__imod__")
  rule T **= O:Object => augAssign(T, O, '_**_ , "__ipow__")
  rule T >>= O:Object => augAssign(T, O, '_>>_ , "__irshift__")
  rule T <<= O:Object => augAssign(T, O, '_<<_ , "__ilshift__")
  rule T &= O:Object => augAssign(T, O, '_&_ , "__iand__")
  rule T ^= O:Object => augAssign(T, O, '_^_ , "__ixor__")
  rule T |= O:Object => augAssign(T, O, '_|_ , "__ior__")

  context augAssign((HOLE . _:Id), _, _, _)
  context augAssign((HOLE [ _:Expression ]), _, _, _)
  context augAssign((K:K [ HOLE ]), _, _, _) when isKResult(K)

  rule augAssign(T, O, Lbl:KLabel, IX) => augAssign2(T, T, O, Lbl, IX)
  rule augAssign2(T, O, O2:Object, Lbl, IX) => (getmember(O, IX, true, false, false) (O2)) -> ((T, .Expressions) := Lbl(O,,O2))

endmodule
