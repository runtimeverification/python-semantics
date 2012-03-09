module PYTHON-SEMANTICS-ARITHMETIC-OPS
  imports PYTHON-SEMANTICS-OPS

  rule <k> O:Object ** O2:Object => coerceBinary(O, O2, #id "__pow__", #id "__rpow__", "**") ...</k>
  rule <k> - O => coerceUnary(O, #id "__neg__", "unary -") ...</k>
  rule <k> + O => coerceUnary(O, #id "__pos__", "unary +") ...</k>
  rule <k> ~ O => coerceUnary(O, #id "__invert__", "unary ~") ...</k>
  rule <k> O * O2 => coerceBinary(O, O2, #id "__mul__", #id "__rmul__", "*") ...</k>
  rule <k> O floor/ O2 => coerceBinary(O, O2, #id "__floordiv__", #id "__rfloordiv__", "//") ...</k>
  rule <k> O / O2 => coerceBinary(O, O2, #id "__truediv__", #id "__rtruediv__", "/") ...</k>
  rule <k> O % O2 => coerceBinary(O, O2, #id "__mod__", #id "__rmod__", "%") ...</k>
  rule <k> O + O2 => coerceBinary(O, O2, #id "__add__", #id "__radd__", "+") ...</k>
  rule <k> O - O2 => coerceBinary(O, O2, #id "__sub__", #id "__rsub__", "-") ...</k>
  rule <k> O << O2 => coerceBinary(O, O2, #id "__lshift__", #id "__rlshift__", "<<") ...</k>
  rule <k> O >> O2 => coerceBinary(O, O2, #id "__rshift__", #id "__rrshift__", ">>") ...</k>
  rule <k> O & O2 => coerceBinary(O, O2, #id "__and__", #id "__rand__", "&") ...</k>
  rule <k> O ^ O2 => coerceBinary(O, O2, #id "__xor__", #id "__rxor__", "^") ...</k>
  rule <k> O | O2 => coerceBinary(O, O2, #id "__or__", #id "__ror__", "|") ...</k>

  rule <k> O [ O2 ] => (getmember(O, #id "__getitem__", true, false, false) (O2)) -> raiseInternal("TypeError", "object is not subscriptable") ...</k>

end module
