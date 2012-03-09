module PYTHON-SEMANTICS-DICTS
  imports PYTHON-SEMANTICS-LITERALS

  rule <k> invokeBuiltin(obj("keys_dict",_), ListItem(obj(B:Builtin,<oattrs>... "__revision__" |-> N:#Nat "__value__" |-> map(M:Map) ...</oattrs>)), .) => mutable("_mapping" |-> B "__revision__" |-> N "__order__" |-> list(sorted(DeSetify(keys M))) "__index__" |-> 0 "__index2__" |-> 0, ref("dict_keys")) ...</k>

  rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(_,<oattrs>... "__revision__" |-> Rev1:#Nat "_mapping" |-> B ...</oattrs>)), .) => raiseInternal("RuntimeError", "dictionary changed size during iteration") ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev2:#Nat ...</oattrs>
       ...</object> when Rev1 =/=Bool Rev2

  rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(_,<oattrs>... "__revision__" |-> Rev1 "__order__" |-> list(L:List) "__index__" |-> Idx:#Nat "_mapping" |-> B ...</oattrs>)), .) => raise ref("StopIteration") ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev2 ...</oattrs>
       ...</object> when Rev1 ==Bool Rev2 andBool Idx ==Bool lengthList L

  rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(B,_)), .) => ref(key(get(getl(M(get(L, Idx +Int 1))), 0))) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev1 "__order__" |-> list(L) "__index__" |-> (Idx => Idx +Int 1) "__index2__" |-> (Idx2:#Nat => 1) "_mapping" |-> B2:Builtin ...</oattrs>
       ...</object>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev2 "__value__" |-> map(M) ...</oattrs>
       ...</object> when Rev1 ==Bool Rev2 andBool Idx =/=Bool lengthList L andBool Idx2 ==Bool lengthList getl(M(get(L, Idx)))

  rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(B,_)), .) => ref(key(get(getl(M(get(L, Idx))), Idx2))) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev1 "__order__" |-> list(L) "__index__" |-> Idx "__index2__" |-> (Idx2:#Nat => Idx2 +Int 1) "_mapping" |-> B2:Builtin ...</oattrs>
       ...</object>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev2 "__value__" |-> map(M) ...</oattrs>
       ...</object> when Rev1 ==Bool Rev2 andBool Idx =/=Bool lengthList L andBool Idx2 =/=Bool lengthList getl(M(get(L, Idx)))

  rule invokeBuiltin(obj("len_dict",_), ListItem(O), .) => lengthMap mapvalue(O)

  rule invokeBuiltin(obj("getitem_dict",_), ListItem(obj(B,_)) ListItem(Key:Object), .) => ref("hash")(Key) ~> tableLookup(B, 0, Key)
  rule (O:Object => .) ~> tableLookup(_,(_ => intvalue(O)),_)

  syntax K ::= "makeMap" "(" #Nat ")"

  rule invokeBuiltin(obj("new_dict",_), ListItem(O) _, .) => newHelper(O, ref("dict"), .) ~> {}
  rule invokeBuiltin(obj("init_dict",_), ListItem(_:Object), .) => ref("None")
  rule invokeBuiltin(obj("init_list",_), ListItem(O) ListItem(O2:Object), .) => mapping(O2, .Obj) -> iterate(O2, .) ~> makeMap(0)

  rule map(M) ~> makeMap(_) => { DeMapify(M) }

  rule <k> list(_) ~> (. => map(.)) ~> makeMap(_) ...</k>
  rule <k> (. => iterate(O, raiseInternal("TypeError", "cannot convert dictionary update sequence element #" +String Int2String(N) +String "to a sequence"))) ~>  list((ListItem(O) => .) _) ~> map(_) ~> makeMap(N) ...</k>
  rule <k> (list(ListItem(O) ListItem(O2)) => .) ~> list(_) ~> map(_ (. => O |-> O2)) ~> makeMap(N => N +Int 1) ...</k>
  rule <k> list(L) ~> list(_) ~> map(_) ~> makeMap(N) => raiseInternal("ValueError", "dictionary update sequence element #" +String Int2String(N) +String " has length " +String Int2String(lengthList L) +String "; 2 is required") ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> makeMap(_) ...</k>

end module
