module PYTHON-SEMANTICS-TUPLES
  imports PYTHON-SEMANTICS-SLICING

  rule invokeBuiltin(obj("add_tuple",_), ListItem(O:Object) ListItem(O2:Object), .) => test(and(istype(O, ref("tuple")), istype(O2, ref("tuple"))), immutable(list(listvalue(O) listvalue(O2)),ref("tuple")), raiseInternal("TypeError", "can only concatenate tuple to tuple"))

  rule invokeBuiltin(obj("contains_tuple",_), ListItem(O) ListItem(O2), .) => contains(list(listvalue(O)), O2)

  rule invokeBuiltin(obj("getitem_tuple",_), ListItem(O) ListItem(O2), .) => test(istype(O2, ref("int")), test(intvalue(O2) >=Int -Int lengthList listvalue(O) andBool intvalue(O2) <Int lengthList listvalue(O), test(intvalue(O2) >=Int 0, ref(get(listvalue(O), intvalue(O2))), ref(get(listvalue(O), lengthList listvalue(O) +Int intvalue(O2)))), raiseInternal("IndexError", "tuple index out of range")), test(istype(O2, ref("slice")), ref("tuple")(slice(O, O2)), raiseInternal("TypeError", "tuple indices must be integers or slices")))

  rule invokeBuiltin(obj("len_tuple",_), ListItem(O), .) => lengthList listvalue(O)

  rule invokeBuiltin(obj("new_tuple",_), ListItem(O), .) => newHelper(O, ref("tuple"), .) ~> immutable(list(.), O)
  rule invokeBuiltin(obj("new_tuple",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("tuple"), .) ~> iterate(O2, .) ~> immutable(list(.), O)
  rule (list(L:List) => .) ~> immutable(list(_ => L), _)

end module
