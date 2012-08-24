module PYTHON-SEMANTICS-ARITHMETIC-OPS
  imports PYTHON-SEMANTICS-OPS

  rule <k> O:Object ** O2:Object => coerceBinary(O, O2, String2Id("__pow__"), String2Id("__rpow__"), "**") ...</k>
  rule <k> - O => coerceUnary(O, String2Id("__neg__"), "unary -") ...</k>
  rule <k> + O => coerceUnary(O, String2Id("__pos__"), "unary +") ...</k>
  rule <k> ~ O => coerceUnary(O, String2Id("__invert__"), "unary ~") ...</k>
  rule <k> O * O2 => coerceBinary(O, O2, String2Id("__mul__"), String2Id("__rmul__"), "*") ...</k>
  rule <k> O floor/ O2 => coerceBinary(O, O2, String2Id("__floordiv__"), String2Id("__rfloordiv__"), "//") ...</k>
  rule <k> O / O2 => coerceBinary(O, O2, String2Id("__truediv__"), String2Id("__rtruediv__"), "/") ...</k>
  rule <k> O % O2 => coerceBinary(O, O2, String2Id("__mod__"), String2Id("__rmod__"), "%") ...</k>
  rule <k> O + O2 => coerceBinary(O, O2, String2Id("__add__"), String2Id("__radd__"), "+") ...</k>
  rule <k> O - O2 => coerceBinary(O, O2, String2Id("__sub__"), String2Id("__rsub__"), "-") ...</k>
  rule <k> O << O2 => coerceBinary(O, O2, String2Id("__lshift__"), String2Id("__rlshift__"), "<<") ...</k>
  rule <k> O >> O2 => coerceBinary(O, O2, String2Id("__rshift__"), String2Id("__rrshift__"), ">>") ...</k>
  rule <k> O & O2 => coerceBinary(O, O2, String2Id("__and__"), String2Id("__rand__"), "&") ...</k>
  rule <k> O ^ O2 => coerceBinary(O, O2, String2Id("__xor__"), String2Id("__rxor__"), "^") ...</k>
  rule <k> O | O2 => coerceBinary(O, O2, String2Id("__or__"), String2Id("__ror__"), "|") ...</k>

  rule <k> O [ O2 ] => (getmember(O, String2Id("__getitem__"), true, false, false) (O2)) -> raiseInternal("TypeError", "object is not subscriptable") ...</k>

endmodule
