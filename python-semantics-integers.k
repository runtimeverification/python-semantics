require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-INTEGERS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  rule <k> invokeBuiltin(obj("lt_int",_), ListItem(O:Object) ListItem(O2:Object), .) => binaryOp(O, O2, "int", "int", bool(intvalue(O) <Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("gt_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", bool(intvalue(O) >Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("le_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", bool(intvalue(O) <=Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ge_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", bool(intvalue(O) >=Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("eq_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", bool(intvalue(O) ==Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ne_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", bool(intvalue(O) =/=Int intvalue(O2))) ...</k>

  rule <k> invokeBuiltin(obj("bool_int",_), ListItem(O), .) => bool(plbool(O)) ...</k>

  rule <k> invokeBuiltin(obj("add_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", intvalue(O) +Int intvalue(O2)) ...</k>
  rule <k> invokeBuiltin(obj("radd_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("add_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("sub_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", intvalue(O) -Int intvalue(O2)) ...</k>
  rule <k> invokeBuiltin(obj("rsub_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("sub_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("mul_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", intvalue(O) *Int intvalue(O2)) ...</k>
  rule <k> invokeBuiltin(obj("rmul_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("mul_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("truediv_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", #if intvalue(O2) ==Int 0 #then raiseInternal("ZeroDivisionError", "division by zero") #else Int2Float(intvalue(O)) /Float Int2Float(intvalue(O2)) #fi) ...</k>
  rule <k> invokeBuiltin(obj("rtruediv_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("truediv_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("floordiv_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", #if intvalue(O2) ==Int 0 #then raiseInternal("ZeroDivisionError", "integer division by zero") #else intvalue(O) /Int intvalue(O2) #fi) ...</k>
  rule <k> invokeBuiltin(obj("rfloordiv_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("floordiv_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("mod_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", #if intvalue(O2) ==Int 0 #then raiseInternal("ZeroDivisionError", "modulo by zero") #else intvalue(O) %Int intvalue(O2) #fi) ...</k>
  rule <k> invokeBuiltin(obj("rmod_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("mod_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("pow_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", #if intvalue(O2) >=Int 0 #then intvalue(O) ^Int intvalue(O2) #else #if intvalue(O) ==Int 0 #then raiseInternal("ZeroDivisionError", "0.0 cannot be raised to a negative power") #else Int2Float(1) /Float Int2Float(intvalue(O) ^Int absInt(intvalue(O2))) #fi #fi) ...</k>
  rule <k> invokeBuiltin(obj("rpow_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("pow_int"), ListItem(O2) ListItem(O), .) ...</k>

  //TODO: 3-argument pow

  rule <k> invokeBuiltin(obj("lshift_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", #if intvalue(O2) >=Int 0 #then intvalue(O) <<Int intvalue(O2) #else raiseInternal("ValueError", "negative shift count") #fi) ...</k>
  rule <k> invokeBuiltin(obj("rlshift_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("lshift_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("rshift_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", #if intvalue(O2) >=Int 0 #then intvalue(O) >>Int intvalue(O2) #else raiseInternal("ValueError", "negative shift count") #fi) ...</k>
  rule <k> invokeBuiltin(obj("rrshift_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("rshift_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("and_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", (intvalue(O) &Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("rand_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("and_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("xor_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", (intvalue(O) xorInt intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("rxor_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("xor_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("or_int",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "int", "int", (intvalue(O) |Int intvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ror_int",_), ListItem(O) ListItem(O2), .) => invokeBuiltin(ref("or_int"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("neg_int",_), ListItem(O), .) => unaryOp(O, "int", 0 -Int intvalue(O)) ...</k>
  rule <k> invokeBuiltin(obj("pos_int",_), ListItem(O), .) => unaryOp(O, "int", intvalue(O)) ...</k>
  rule <k> invokeBuiltin(obj("abs_int",_), ListItem(O), .) => unaryOp(O, "int", absInt(intvalue(O))) ...</k>
  rule <k> invokeBuiltin(obj("invert_int",_), ListItem(O), .) => unaryOp(O, "int", ~Int intvalue(O)) ...</k>

  //TODO: string conversion
  rule invokeBuiltin(obj("new_int",_), ListItem(O), .) => newHelper(O, ref("int"), SetItem("bool")) ~> immutable(0, O)
  rule invokeBuiltin(obj("new_int",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("int"), SetItem("bool")) ~> immutable(intvalue(O . String2Id("__int__") (.Arguments)), O)
  context immutable(intvalue(HOLE), _)

  rule invokeBuiltin(obj("int_int",_), ListItem(O), .) => O

endmodule
