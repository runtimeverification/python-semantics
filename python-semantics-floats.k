require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-FLOATS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  rule invokeBuiltin(obj("float.__lt__",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("int")), binaryOp(O, O2, "float", "int", bool(floatvalue(O) <Float Int2Float(intvalue(O2)))), binaryOp(O, O2, "float", "float", bool(floatvalue(O) <Float floatvalue(O2))))
  rule invokeBuiltin(obj("float.__gt__",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("int")), binaryOp(O, O2, "float", "int", bool(floatvalue(O) >Float Int2Float(intvalue(O2)))), binaryOp(O, O2, "float", "float", bool(floatvalue(O) >Float floatvalue(O2))))
  rule invokeBuiltin(obj("float.__le__",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("int")), binaryOp(O, O2, "float", "int", bool(floatvalue(O) <=Float Int2Float(intvalue(O2)))), binaryOp(O, O2, "float", "float", bool(floatvalue(O) <=Float floatvalue(O2))))
  rule invokeBuiltin(obj("float.__ge__",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("int")), binaryOp(O, O2, "float", "int", bool(floatvalue(O) >=Float Int2Float(intvalue(O2)))), binaryOp(O, O2, "float", "float", bool(floatvalue(O) >=Float floatvalue(O2))))
  rule invokeBuiltin(obj("float.__eq__",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("int")), binaryOp(O, O2, "float", "int", bool(floatvalue(O) ==Float Int2Float(intvalue(O2)))), binaryOp(O, O2, "float", "float", bool(floatvalue(O) ==Float floatvalue(O2))))
  rule invokeBuiltin(obj("float.__ne__",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("int")), binaryOp(O, O2, "float", "int", bool(floatvalue(O) =/=Float Int2Float(intvalue(O2)))), binaryOp(O, O2, "float", "float", bool(floatvalue(O) =/=Float floatvalue(O2))))

  rule invokeBuiltin(obj("float.__int__",_), ListItem(O), .) => unaryOp(O, "float", Float2Int(floatvalue(O)))

  rule invokeBuiltin(obj("float.__new__",_), ListItem(O:Object), .) => newHelper(O, ref("float"), .) ~> immutable(0.0, O)
  rule invokeBuiltin(obj("float.__new__",_), ListItem(O:Object) ListItem(O2:Object), .) => newHelper(O, ref("float"), .) ~> immutable(floatvalue(getmember(O2, "__float__", true, false, true) (.Arguments)), O)
  context immutable(floatvalue(HOLE), _)

endmodule
