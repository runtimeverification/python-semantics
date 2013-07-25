require "python-semantics-ops.k"

module PYTHON-SEMANTICS-ARITHMETIC-OPS
  imports PYTHON-SEMANTICS-OPS

  rule O:Object ** O2:Object => coerceBinary(O, O2, "__pow__", "__rpow__", "**")
  rule - O => coerceUnary(O, "__neg__", "unary -")
  rule + O => coerceUnary(O, "__pos__", "unary +")
  rule ~ O => coerceUnary(O, "__invert__", "unary ~")
  rule O * O2 => coerceBinary(O, O2, "__mul__", "__rmul__", "*")
  rule O floor/ O2 => coerceBinary(O, O2, "__floordiv__", "__rfloordiv__", "//")
  rule O / O2 => coerceBinary(O, O2, "__truediv__", "__rtruediv__", "/")
  rule O % O2 => coerceBinary(O, O2, "__mod__", "__rmod__", "%")
  rule O + O2 => coerceBinary(O, O2, "__add__", "__radd__", "+")
  rule O - O2 => coerceBinary(O, O2, "__sub__", "__rsub__", "-")
  rule O << O2 => coerceBinary(O, O2, "__lshift__", "__rlshift__", "<<")
  rule O >> O2 => coerceBinary(O, O2, "__rshift__", "__rrshift__", ">>")
  rule O & O2 => coerceBinary(O, O2, "__and__", "__rand__", "&")
  rule O ^ O2 => coerceBinary(O, O2, "__xor__", "__rxor__", "^")
  rule O | O2 => coerceBinary(O, O2, "__or__", "__ror__", "|")

  rule [subscript]: <k> O:Object [ O2:Object ] => (getmember(O, "__getitem__", true, false, false) (O2)) -> raiseInternal("TypeError", "object is not subscriptable") ...</k>

endmodule
