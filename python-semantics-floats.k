require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-FLOATS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  //rule <k> invokeBuiltin(obj("lt_float",_), ListItem(O:Object) ListItem(O2:Object), .) => binaryOp(O, O2, "float", "float", bool(floatvalue(O) <Float floatvalue(O2))) ...</k>
  //rule <k> invokeBuiltin(obj("gt_float",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "float", "float", bool(floatvalue(O) >Float floatvalue(O2))) ...</k>
  //rule <k> invokeBuiltin(obj("le_float",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "float", "float", bool(floatvalue(O) <=Float floatvalue(O2))) ...</k>
  //rule <k> invokeBuiltin(obj("ge_float",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "float", "float", bool(floatvalue(O) >=Float floatvalue(O2))) ...</k>
  //rule <k> invokeBuiltin(obj("eq_float",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "float", "float", bool(floatvalue(O) ==Float floatvalue(O2))) ...</k>
  //rule <k> invokeBuiltin(obj("ne_float",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "float", "float", bool(floatvalue(O) =/=Float floatvalue(O2))) ...</k>

endmodule
