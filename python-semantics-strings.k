module PYTHON-SEMANTICS-STRINGS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS
  imports MACHINE-INTEGERS

  rule <k> invokeBuiltin(obj("add_str",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("str")), strvalue(O) +String strvalue(O2), raiseInternal("TypeError", ("Can't convert '" + name(gettype(O2)) + "' object to str implicitly"))) ...</k>

  rule <k> invokeBuiltin(obj("eq_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", bool(strvalue(O) ==String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ne_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", bool(strvalue(O) =/=String strvalue(O2))) ...</k>

  rule <k> invokeBuiltin(obj("hash_str",_), ListItem(O), .) => test(lengthString(strvalue(O)) ==Int 0, 0, accumulate(strvalue(O), asciiString(substrString(strvalue(O), 0, 1)) <<Int 7, lengthString(strvalue(O)))) ...</k>

  syntax ObjRef ::= "accumulate" "(" String "," Int "," Int ")"

  rule <k> accumulate((S:String => substrString(S, 1, lengthString(S) -Int 1)), (I:Int => (mult(Imag, I, Width) xorInt asciiString(substrString(S, 0, 1)))), _) ...</k>
       <hashInfo> ListItem(Width:Nat) ListItem(_) ListItem(_) ListItem(_) ListItem(Imag:Int) </hashInfo> when lengthString(S) =/=Int 0

  rule <k> accumulate("", I, Len:Nat) => test((I xorInt Len) ==Int -1, -2, (I xorInt Len)) ...</k>

endmodule
