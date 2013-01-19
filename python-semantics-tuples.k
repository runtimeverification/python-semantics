require "python-semantics-lists.k"
require "machine-integers.k"

module PYTHON-SEMANTICS-TUPLES
  imports PYTHON-SEMANTICS-LISTS
  imports MACHINE-INTEGERS

  rule invokeBuiltin(obj("add_tuple",_), ListItem(O:Object) ListItem(O2:Object), .) => test(and(istype(O, ref("tuple")), istype(O2, ref("tuple"))), immutable(list(listvalue(O) listvalue(O2)),ref("tuple")), raiseInternal("TypeError", "can only concatenate tuple to tuple"))

  rule invokeBuiltin(obj("contains_tuple",_), ListItem(O) ListItem(O2), .) => contains(list(listvalue(O)), O2)

  rule invokeBuiltin(obj("getitem_tuple",_), ListItem(O) ListItem(O2), .) => test(istype(O2, ref("int")), test(intvalue(O2) >=Int 0 -Int lengthList listvalue(O) andBool intvalue(O2) <Int lengthList listvalue(O), test(intvalue(O2) >=Int 0, get(listvalue(O), intvalue(O2)), get(listvalue(O), lengthList listvalue(O) +Int intvalue(O2))), raiseInternal("IndexError", "tuple index out of range")), test(istype(O2, ref("slice")), ref("tuple")(slice(O, O2)), raiseInternal("TypeError", "tuple indices must be integers or slices")))

  rule invokeBuiltin(obj("len_tuple",_), ListItem(O), .) => lengthList listvalue(O)

  rule invokeBuiltin(obj("new_tuple",_), ListItem(O), .) => newHelper(O, ref("tuple"), .) ~> immutable(list(.), O)
  rule invokeBuiltin(obj("new_tuple",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("tuple"), .) ~> iterate(O2, .) ~> immutable(list(.), O)
  rule (list(L:List) => .) ~> immutable(list(_ => Refify(Idify(L))), _)

  rule invokeBuiltin(obj("eq_tuple",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "tuple", "tuple", (ref("bool") (equalList(listvalue(O), (listvalue(O2))))))
  rule invokeBuiltin(obj("ne_tuple",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "tuple", "tuple", not equalList(listvalue(O), listvalue(O2)))

  rule <k> invokeBuiltin(obj("hash_tuple",_), ListItem(O), .) => accumulateTuple(Begin, Mult, listvalue(O)) ...</k>
       <hashInfo>... ListItem(Mult) ListItem(Begin) ListItem(_) ListItem(_) </hashInfo>

  syntax ObjRef ::= accumulateTuple(Int, Int, List)

  rule accumulateTuple(Current, Mult, ListItem(ref(B)) L) => ref("hash")(ref(B), .Arguments) ~> accumulateTuple(Current, Mult, ListItem(HOLE) L) [heat]
  rule O ~> accumulateTuple(Current, Mult, ListItem(HOLE) L) => accumulateTuple(Current, Mult, ListItem(intvalue(O)) L) [cool]
  rule <k> accumulateTuple(Current, Mult, ListItem(I:Int) L) => accumulateTuple(mult(Current xorInt I, Mult, Width), Mult +Int Addend +Int lengthList L +Int lengthList L, L) ...</k>
       <hashInfo> ListItem(Width) _ ListItem(Addend) ListItem(_) </hashInfo>
  rule <k> accumulateTuple(Current, _, .List) => test(add(Current, End, Width) ==Int -1, -2, add(Current, End, Width)) ...</k>
       <hashInfo> ListItem(Width) _ ListItem(End) </hashInfo>

endmodule
