require "python-semantics-literals.k"

module PYTHON-SEMANTICS-SETS
  imports PYTHON-SEMANTICS-LITERALS

  rule invokeBuiltin(obj("new_set",_), ListItem(O) _, .) => newHelper(O, ref("set"), .) ~> {.Expressions}
  rule invokeBuiltin(obj("init_set",_), ListItem(O), .) => ref("None")
  rule invokeBuiltin(obj("init_set",_), ListItem(O) ListItem(O2), .) => iterate(O2, .) ~> makeSet(O)

  syntax K ::= makeSet(Expression) [strict]

  rule (. => O |= {O2}) ~> list((ListItem(O2) => .) _) ~> makeSet(O)
  rule list(.) ~> makeSet(_) => ref("None")

  rule [ior-set]: invokeBuiltin(obj("ior_set",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "set", "set", processSet(O, setvalue(O2)))

  rule invokeBuiltin(obj("eq_set",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "set", "set", bool(lengthList setvalue(O) ==Int lengthList setvalue(O2)) and subset(setvalue(O), O2))
  rule invokeBuiltin(obj("ne_set",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "set", "set", not ref("ne_set")(O, O2))
  rule invokeBuiltin(obj("lt_set",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "set", "set", bool(lengthList setvalue(O) <Int lengthList setvalue(O2)) and subset(setvalue(O), O2))
  rule invokeBuiltin(obj("le_set",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "set", "set", subset(setvalue(O), O2))

  syntax ObjRef ::= subset(List, Expression) [strict(2)]
  rule subset(ListItem(Element) L, Set) => Element in Set and subset(L, Set)
  rule subset(., _) => ref("True")

  rule invokeBuiltin(obj("contains_set",_), ListItem(O) ListItem(O2), .) => contains(list(setvalue(O)), O2)
endmodule
