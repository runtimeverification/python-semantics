require "python-semantics-common.k"

module PYTHON-SEMANTICS-EXCEPTIONS
  imports PYTHON-SEMANTICS-COMMON

  rule invokeBuiltin(obj("init_baseexception",_), ListItem(obj(B:Builtin,_)) L:List, .) => setref(B, "args", immutable(list(Refify(Idify(L))), ref("tuple"))) ~> ref("None")

endmodule
