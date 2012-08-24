module PYTHON-SEMANTICS-LISTS
  imports PYTHON-SEMANTICS-SLICING

  syntax K ::= "setvalue" "(" Object ")"

  rule invokeBuiltin(obj("add_list",_), ListItem(O:Object) ListItem(O2:Object), .) => test(and(istype(O, ref("list")), istype(O2, ref("list"))), mutable(list(listvalue(O) listvalue(O2)),ref("list")), raiseInternal("TypeError", "can only concatenate list to list"))

  rule invokeBuiltin(obj("getitem_list",_), ListItem(O) ListItem(O2), .) => test(istype(O2, ref("int")), test(intvalue(O2) >=Int 0 -Int lengthList listvalue(O) andBool intvalue(O2) <Int lengthList listvalue(O), test(intvalue(O2) >=Int 0, ref(get(listvalue(O), intvalue(O2))), ref(get(listvalue(O), lengthList listvalue(O) +Int intvalue(O2)))), raiseInternal("IndexError", "list index out of range")), test(istype(O2, ref("slice")), ref("list")(slice(O, O2)), raiseInternal("TypeError", "list indices must be integers or slices")))

  rule invokeBuiltin(obj("len_list",_), ListItem(O), .) => lengthList listvalue(O)

  rule invokeBuiltin(obj("new_list",_), ListItem(O) _, .) => newHelper(O, ref("list"), .) ~> mutable(list(.), O)
  rule invokeBuiltin(obj("init_list",_), ListItem(_:Object), .) => ref("None")
  rule invokeBuiltin(obj("init_list",_), ListItem(O) ListItem(O2), .) => iterate(O2, .) ~> setvalue(O)

  rule <k> list(L:List) ~> setvalue(obj(B:Builtin,_)) => ref("None") ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> (_ => list(Idify(L))) ...</oattrs>
       ...</object>

  rule invokeBuiltin(obj("eq_list",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "list", "list", (ref("bool") (equalList(listvalue(O), (listvalue(O2))))))
  rule invokeBuiltin(obj("ne_list",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "list", "list", not equalList(listvalue(O), listvalue(O2)))

  syntax ObjRef ::= "equalList" "(" List "," List ")"

  rule equalList(ListItem(B) L, ListItem(B2:Builtin) L2:List) => ref(B) == ref(B2) and equalList(L, L2)
  rule equalList(ListItem(_) _, .) => ref("False")
  rule equalList(., ListItem(_) _) => ref("False")
  rule equalList(.,.) => ref("True")

endmodule
