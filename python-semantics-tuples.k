require "python-semantics-lists.k"
require "machine-integers.k"

module PYTHON-SEMANTICS-TUPLES
  imports PYTHON-SEMANTICS-LISTS
  imports MACHINE-INTEGERS

  rule invokeBuiltin("tuple.__add__","self" |-> Self:Object "other" |-> Other:Object) =>
    if istype(Self, ref("tuple")) and istype(Other, ref("tuple")) :
      return immutable(list(listvalue(Self) listvalue(Other)), ref("tuple"))
    else:
      raiseInternal("TypeError", "cano only concatenate tuple to tuple")

  //rule invokeBuiltin(obj("contains_tuple",_), ListItem(O) ListItem(O2), .) => contains(list(listvalue(O)), O2)

  rule invokeBuiltin("tuple.__getitem__","self" |-> Self:Object "key" |-> Key:Object) =>
    if istype(Key, ref("int")) :
      (if intvalue(Key) >=Int 0 -Int lengthList listvalue(Self) andBool intvalue(Key) <Int lengthList listvalue(Self) :
        (if intvalue(Key) >=Int 0 :
          return get(listvalue(Self), intvalue(Key))
        else:
          return get(listvalue(Self), lengthList listvalue(Self) +Int intvalue(Key)))
      else:
         raiseInternal("IndexError", "tuple index out of range"))
    else:
      if istype(Key, ref("slice")) :
        return ref("tuple")(slice(Self, Key))
      else:
        raiseInternal("TypeError", "tuple indices must be integers or slices")

  rule invokeBuiltin("tuple.__len__", "self" |-> O:Object) => return lengthList listvalue(O)

  //rule invokeBuiltin(obj("new_tuple",_), ListItem(O), .) => newHelper(O, ref("tuple"), .) ~> immutable(list(.), O)
  //rule invokeBuiltin(obj("new_tuple",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("tuple"), .) ~> iterate(O2, .) ~> immutable(list(.), O)
  rule (list(L:List) => .) ~> immutable(list(_ => Refify(Idify(L))), _)

  //rule invokeBuiltin(obj("eq_tuple",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "tuple", "tuple", (ref("bool") (equalList(listvalue(O), (listvalue(O2))))))
  //rule invokeBuiltin(obj("ne_tuple",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "tuple", "tuple", not equalList(listvalue(O), listvalue(O2)))

  //rule <k> invokeBuiltin(obj("hash_tuple",_), ListItem(O), .) => accumulateTuple(Begin, Mult, listvalue(O)) ...</k>
  //     <constants>... "sys.hash_info.imag" |-> Mult "tuple.__hash__:begin" |-> Begin ...</constants>

  syntax ObjRef ::= accumulateTuple(Int, Int, List)

  rule accumulateTuple(Current, Mult, ListItem(ref(B)) L) => ref("hash")(ref(B), .Arguments) ~> accumulateTuple(Current, Mult, ListItem(HOLE) L) [heat]
  rule O ~> accumulateTuple(Current, Mult, ListItem(HOLE) L) => accumulateTuple(Current, Mult, ListItem(intvalue(O)) L) [cool]
  rule <k> accumulateTuple(Current, Mult, ListItem(I:Int) L) => accumulateTuple(mult(Current xorInt I, Mult, Width), Mult +Int Addend +Int lengthList L +Int lengthList L, L) ...</k>
       <constants>... "sys.hash_info.width" |-> Width "tuple.__hash__:addend" |-> Addend ...</constants>
  rule <k> accumulateTuple(Current, _, .List) => test(add(Current, End, Width) ==Int -1, -2, add(Current, End, Width)) ...</k>
       <constants>... "sys.hash_info.width" |-> Width "tuple.__hash__:end" |-> End ...</constants>

endmodule
