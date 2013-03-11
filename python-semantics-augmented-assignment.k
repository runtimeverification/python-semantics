require "python-semantics-common.k"

module PYTHON-SEMANTICS-AUGMENTED-ASSIGNMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= augAssign(Target, Object, KLabel, Exp)
  syntax K ::= augAssign2(Target, Exp, Object, KLabel, Id) [strict(2)]
  syntax K ::= augAssign3(Target, Object, Object, KLabel, Exp) [strict(5)]

  rule T:Target += O:Object => augAssign(T, O, '_+_ , "__iadd__")
  rule T -= O:Object => augAssign(T, O, '_-_ , "__isub__")
  rule T *= O:Object => augAssign(T, O, '_*_ , "__imul__")
  rule T /= O:Object => augAssign(T, O, '_/_ , "__itruediv__")
  rule T floor/= O:Object => augAssign(T, O, '_FloorDiv_ , "__ifloordiv__")
  rule T %= O:Object => augAssign(T, O, '_%_ , "__imod__")
  rule T **= O:Object => augAssign(T, O, '_**_ , "__ipow__")
  rule T >>= O:Object => augAssign(T, O, '_>>_ , "__irshift__")
  rule T <<= O:Object => augAssign(T, O, '_<<_ , "__ilshift__")
  rule T &= O:Object => augAssign(T, O, '_&_ , "__iand__")
  rule T ^= O:Object => augAssign(T, O, '_^_ , "__ixor__")
  rule T |= O:Object => augAssign(T, O, '_|_ , "__ior__")

  context augAssign((HOLE . _:Id), _, _, _)
  context augAssign((HOLE [ _:Exp ]), _, _, _)
  context augAssign((K:K [ HOLE ]), _, _, _) when isKResult(K)

  rule augAssign(T, O, Lbl:KLabel, IX) => augAssign2(T, T, O, Lbl, IX)
  rule augAssign2(T, O, O2:Object, Lbl, IX) => augAssign3(T, O, O2, Lbl, getmember(O, IX, true, false, false)) 
  rule augAssign3(T, O, O2:Object, Lbl, IO:Object) => IO(O2) ;
  rule augAssign3(T:Target, O, O2, Lbl, .Obj) => (T) = Lbl(O,,O2)

endmodule
