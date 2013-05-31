require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-BYTES
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  //TODO: memoryview

  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls), .) => newHelper(Cls, ref("bytes"), .Set) ~> immutable("", Cls)
  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls) ListItem(Source:Object), .) => test(istype(Source, ref("str")), raiseInternal("TypeError", "string argument without an encoding"), test(hasmember(Source, "__index__"), immutable(charString(0), Cls) * ref("index")(Source), iterate(Source, .) ~> makebytes(.List, "", Cls)))
  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls) ListItem(Source) ListItem(Encoding), .) => test(istype(Source, ref("str")), Source . String2Id("encode") (Encoding), invokeBuiltin(ref("new_bytes"), ListItem(Cls) ListItem(Source), .))
  rule invokeBuiltin(obj("new_bytes",_), ListItem(Cls) ListItem(Source) ListItem(Encoding) ListItem(Errors), .) => test(istype(Source, ref("str")), Source . String2Id("encode") (Encoding, Errors), invokeBuiltin(ref("new_bytes"), ListItem(Cls) ListItem(Source), .))

  syntax K ::= makebytes(List, String, Object)
  rule list((ListItem(O:Object) => .) _) ~> makebytes(_ (. => ListItem(ref("index")(O))), _, _)
  context makebytes(L ListItem(HOLE) _, _, _) when all(L, isKResult)
  rule (list(.) => .) ~> makebytes(_, _, _)
  rule makebytes((ListItem(O:Object) => .) L, (S => S +String charString(intvalue(O))), _) when all(L, isKResult) andBool intvalue(O) >=Int 0 andBool intvalue(O) <Int 256
  rule makebytes(ListItem(O) _, _, _) => raiseInternal("ValueError", "bytes must be in range(0, 256)") when intvalue(O) <Int 0 orBool intvalue(O) >=Int 256
  rule makebytes(., S, Cls) => immutable(S, Cls)

  rule invokeBuiltin(obj("add_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", b strvalue(O) +String strvalue(O2))
  rule invokeBuiltin(obj("radd_bytes",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("add_bytes"), ListItem(O) ListItem(O2), .)
  rule invokeBuiltin(obj("mul_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "int", b strvalue(O) *String intvalue(O2))
  rule invokeBuiltin(obj("rmul_bytes",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("mul_bytes"), ListItem(O) ListItem(O2), .)

  rule invokeBuiltin(obj("lt_bytes",_), ListItem(O:Object) ListItem(O2:Object), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) <String strvalue(O2)))
  rule invokeBuiltin(obj("gt_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) >String strvalue(O2)))
  rule invokeBuiltin(obj("le_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) <=String strvalue(O2)))
  rule invokeBuiltin(obj("ge_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) >=String strvalue(O2)))
  rule invokeBuiltin(obj("eq_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) ==String strvalue(O2)))
  rule invokeBuiltin(obj("ne_bytes",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "bytes", "bytes", bool(strvalue(O) =/=String strvalue(O2)))

  syntax #Id ::= "encode"
  rule invokeBuiltin(obj("bytearray.__new__",_), ListItem(Cls) L:List, M:Map) => newHelper(Cls, ref("bytearray"), .) ~> mutable("", Cls)
  rule invokeBuiltin(obj("bytearray.__init__",_), ListItem(Self), .) => ref("None")
  rule invokeBuiltin(obj("bytearray.__init__",_), ListItem(Self) ListItem(Source:Object), .) => test(istype(Source, ref("str")), raiseInternal("TypeError", "string argument without an encoding"), test(hasmember(Source, "__index__"), setBytearrayValue("\000" * ref("index")(Source), Self), setBytearrayValue(iterate(Source, .), Self))) ~> ref("None")
  rule invokeBuiltin(obj("bytearray.__init__",_), ListItem(Self) ListItem(Source:Object) ListItem(Encoding:Object), .) => test(istype(Source, ref("str")), setBytearrayValue(Source . encode(Encoding), Self), ref("bytearray.__init__")(Self, Source))
  rule invokeBuiltin(obj("bytearray.__init__",_), ListItem(Self) ListItem(Source:Object) ListItem(Encoding:Object) ListItem(Errors:Object), .) => test(istype(Source, ref("str")), setBytearrayValue(Source . encode(Encoding, Errors), Self), ref("bytearray.__init__")(Self, Source))
  syntax K ::= setBytearrayValue(Exp, Exp) [strict]
  rule setBytearrayValue(O:Object, Self:Object) => setattr(id(Self), "__value__", strvalue(O))
  rule (. => ref("index")(O)) ~> setBytearrayValue(list((ListItem(O:Object) => .) L:List), (Self:Object => ref(id(Self))))
  rule (O:Object => setattr(id(Self), "__value__", getattr(Self, "__value__") +String charString(intvalue(O)))) ~> setBytearrayValue(_, Self) when intvalue(O) >=Int 0 andBool intvalue(O) <Int 256
  rule O:Object ~> setBytearrayValue(_, _) => raiseInternal("ValueError", "byte must be in range(0, 256)") when intvalue(O) <Int 0 orBool intvalue(O) >=Int 256

endmodule
