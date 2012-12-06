require "python-semantics-boolean-ops.k"
require "machine-integers.k"

module PYTHON-SEMANTICS-STRINGS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS
  imports MACHINE-INTEGERS

  rule <k> invokeBuiltin(obj("add_str",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("str")), strvalue(O) +String strvalue(O2), raiseInternal("TypeError", ("Can't convert '" + name(gettype(O2)) + "' object to str implicitly"))) ...</k>

  rule <k> invokeBuiltin(obj("eq_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", bool(strvalue(O) ==String strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ne_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", bool(strvalue(O) =/=String strvalue(O2))) ...</k>

  rule <k> invokeBuiltin(obj("hash_str",_), ListItem(O), .) => test(lengthString(strvalue(O)) ==Int 0, 0, accumulate(strvalue(O), (asciiString(substrString(strvalue(O), 0, 1)) <<Int 7) xorInt hashPrefix(Seed, Width), lengthString(strvalue(O)))) ...</k>
       <hashSeed> Seed:Int </hashSeed>
       <hashInfo> ListItem(Width:Int) ...</hashInfo>

  syntax ObjRef ::= accumulate(String, Int, Int)
  syntax Int ::= hashPrefix(Int, Int) [function]
               | hashSuffix(Int, Int) [function]

  rule hashSuffix(Seed, Width) => wrap(lcgRandom(Seed, Width /Int 4, Width) >>Int Width, Width)
  rule hashPrefix(Seed, Width) => wrap(lcgRandom(Seed, Width /Int 4, Width) &Int (2 ^Int Width -Int 1), Width)

  rule <k> accumulate((S:String => substrString(S, 1, lengthString(S) -Int 1)), (I:Int => (mult(Imag, I, Width) xorInt asciiString(substrString(S, 0, 1)))), _) ...</k>
       <hashInfo> ListItem(Width:Nat) ListItem(_) ListItem(_) ListItem(_) ListItem(Imag:Int) </hashInfo> when lengthString(S) =/=Int 0

  rule <k> accumulate("", I, Len:Nat) => test((I xorInt Len xorInt hashSuffix(Seed, Width)) ==Int -1, -2, (I xorInt Len xorInt hashSuffix(Seed, Width))) ...</k>
       <hashSeed> Seed:Int </hashSeed>
       <hashInfo> ListItem(Width:Int) ...</hashInfo>

  

  rule invokeBuiltin(obj("rpartition_str",_), ListItem(O) ListItem(Sep), .) => test(istype(Sep, ref("str")), #if rfindString(strvalue(O), strvalue(Sep), lengthString(strvalue(O))) ==Int -1 #then tuple("", "", strvalue(O), .Expressions) #else tuple(substrString(strvalue(O), 0, rfindString(strvalue(O), strvalue(Sep), lengthString(strvalue(O)))), strvalue(Sep), substrString(strvalue(O), rfindString(strvalue(O), strvalue(Sep), lengthString(strvalue(O))) +Int lengthString(strvalue(Sep)), lengthString(strvalue(O))), .Expressions) #fi, raiseInternal("TypeError", "Cannot convert object to str implicitly"))

endmodule
