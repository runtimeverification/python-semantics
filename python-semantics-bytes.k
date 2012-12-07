require "python-semantics-common.k"

module PYTHON-SEMANTICS-BYTES
  imports PYTHON-SEMANTICS-COMMON

  //TODO: memoryview

  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls), .) => newHelper(Cls, ref("bytes"), .Set) ~> immutable(b "", Cls)
  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls) ListItem(Source), .) => test(istype(Source, ref("str")), raiseInternal("TypeError", "string argument without an encoding"), test(istype(Source, ref("int")), immutable(b "\0", Cls) * Source, iterate(Source, .) ~> makebytes))
  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls) ListItem(Source) ListItem(Encoding), .) => test(istype(Source, ref("str")), Source . String2Id("encode") (Encoding), invokeBuiltin(ref("new_bytes"), ListItem(Cls) ListItem(Source), .))
  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls) ListItem(Source) ListItem(Encoding) ListItem(Errors), .) => test(istype(Source, ref("str")), Source . String2Id("encode") (Encoding, Errors), invokeBuiltin(ref("new_bytes"), ListItem(Cls) ListItem(Source), .))

  rule invokeBuiltin(obj("mul_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "int", strvalue(O) *String intvalue(O2))
  rule invokeBuiltin(obj("rmul_bytes",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("mul_bytes"), ListItem(O) ListItem(O2), .)

  rule <k> invokeBuiltin(obj("lt_bytes",_), ListItem(O:Object) ListItem(O2:Object), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) <String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("gt_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) >String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("le_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) <=String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ge_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) >=String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("eq_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) ==String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ne_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) =/=String strvalue(O2))) ...</k>

endmodule
