require "python-semantics-ops.k"

module PYTHON-SEMANTICS-ARITHMETIC-OPS
  imports PYTHON-SEMANTICS-OPS

  rule <k> O:Object ** O2:Object => coerceBinary(O, O2, "__pow__", "__rpow__", "**") ...</k>
  rule <k> - O => coerceUnary(O, "__neg__", "unary -") ...</k>
  rule <k> + O => coerceUnary(O, "__pos__", "unary +") ...</k>
  rule <k> ~ O => coerceUnary(O, "__invert__", "unary ~") ...</k>
  rule <k> O * O2 => coerceBinary(O, O2, "__mul__", "__rmul__", "*") ...</k>
  rule <k> O floor/ O2 => coerceBinary(O, O2, "__floordiv__", "__rfloordiv__", "//") ...</k>
  rule <k> O / O2 => coerceBinary(O, O2, "__truediv__", "__rtruediv__", "/") ...</k>
  rule <k> O % O2 => coerceBinary(O, O2, "__mod__", "__rmod__", "%") ...</k>
  rule <k> O + O2 => coerceBinary(O, O2, "__add__", "__radd__", "+") ...</k>
  rule <k> O - O2 => coerceBinary(O, O2, "__sub__", "__rsub__", "-") ...</k>
  rule <k> O << O2 => coerceBinary(O, O2, "__lshift__", "__rlshift__", "<<") ...</k>
  rule <k> O >> O2 => coerceBinary(O, O2, "__rshift__", "__rrshift__", ">>") ...</k>
  rule <k> O & O2 => coerceBinary(O, O2, "__and__", "__rand__", "&") ...</k>
  rule <k> O ^ O2 => coerceBinary(O, O2, "__xor__", "__rxor__", "^") ...</k>
  rule <k> O | O2 => coerceBinary(O, O2, "__or__", "__ror__", "|") ...</k>

  rule [subscript]: <k> O [ O2 ] => (getmember(O, "__getitem__", true, false, false) (O2, .Arguments)) -> raiseInternal("TypeError", "object is not subscriptable") ...</k>

endmodule
