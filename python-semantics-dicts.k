require "python-semantics-literals.k"

module PYTHON-SEMANTICS-DICTS
  imports PYTHON-SEMANTICS-LITERALS

  rule invokeBuiltin(obj("keys_dict",_), ListItem(obj(B:Builtin,_)), .) => mutable("_mapping" |-> B, ref("dict_keys"))

  rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(_, <oattrs>... "_mapping" |-> B ...</oattrs>)), .) => mutable("_mapping" |-> B "__revision__" |-> N:Int "__order__" |-> list(sorted(DeSetify(keys M))) "__index__" |-> 0 "__index2__" |-> 0, ref("iterator")) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> N "__value__" |-> map(M:Map) ...</oattrs>
       ...</object>

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B2,_)), .) => raiseInternal("RuntimeError", "dictionary changed size during iteration") ...</k>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev1 "_mapping" |-> B:Builtin ...</oattrs>
       ...</object>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev2:Int ...</oattrs>
       ...</object> when Rev1 =/=Int Rev2

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B2,_)), .) => raise ref("StopIteration") ...</k>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev1 "__order__" |-> list(L) "__index__" |-> (Idx) "_mapping" |-> B:Builtin ...</oattrs>
       ...</object>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev2 ...</oattrs>
       ...</object> when Rev1 ==Int Rev2 andBool Idx ==Int lengthList L

  rule <object>...
         <oattrs>... "__revision__" |-> Rev1 "__order__" |-> list(L) "__index__" |-> (Idx => Idx +Int 1) "__index2__" |-> (Idx2:Int => 0) "_mapping" |-> B2:Builtin ...</oattrs>
       ...</object>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev2 "__value__" |-> map(M) ...</oattrs>
       ...</object> when Rev1 ==Int Rev2 andBool Idx =/=Int lengthList L andBool Idx2 ==Int lengthList getl(M:Map(get(L, Idx))) [structural]

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => ref(key(get(getl(M:Map(get(L:List, Idx))), Idx2))) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev1 "__order__" |-> list(L) "__index__" |-> Idx "__index2__" |-> (Idx2:Int => Idx2 +Int 1) "_mapping" |-> B2:Builtin ...</oattrs>
       ...</object>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev2 "__value__" |-> map(M) ...</oattrs>
       ...</object> when Rev1 ==Int Rev2 andBool Idx =/=Int lengthList L andBool Idx2 =/=Int lengthList getl(M:Map(get(L, Idx)))

  rule invokeBuiltin(obj("iter_dict",_), ListItem(O), .) => ((O . String2Id("keys")) (.Arguments) . String2Id("__iter__")) (.Arguments)

  rule invokeBuiltin(obj("len_dict",_), ListItem(O), .) => lengthMap mapvalue(O)

  rule invokeBuiltin(obj("getitem_dict",_), ListItem(obj(B,_)) ListItem(Key:Object), .) => ref("hash")(Key) ~> tableLookup(B, 0, Key)
  rule (O:Object => .) ~> tableLookup(_,(_ => intvalue(O)),_)

  rule invokeBuiltin(obj("setitem_dict",_), ListItem(O) ListItem(Key) ListItem(Value:Object), .) => processDict(O, Key |-> Value) ; ~> ref("None") 

  rule invokeBuiltin(obj("delitem_dict",_), ListItem(obj(B,_)) ListItem(Key), .) => ref("hash")(Key, .Arguments) ~> tableDelete(B, 0, Key) ~> ref("None")
  rule (O:Object => .) ~> tableDelete(_,(_ => intvalue(O)),_)

  syntax K ::= makeDict(Int, Expression) [strict(2)]

  rule invokeBuiltin(obj("new_dict",_), ListItem(O) _, .) => newHelper(O, ref("dict"), .) ~> {.KeyData}
  rule invokeBuiltin(obj("init_dict",_), ListItem(_:Object), .) => ref("None")
  rule invokeBuiltin(obj("init_dict",_), ListItem(O) ListItem(O2:Object), .) => mapping(O2, .Obj) -> iterate(O2, .) ~> makeDict(0, O)

  rule (. => O[Key], .Expressions := Value) ~> map((Key |-> Value => .) _) ~> makeDict(_, O) 
  rule map(.) ~> makeDict(_, O) => ref(id(O))

  rule <k> list(_) ~> (. => map(.)) ~> makeDict(_, _) ...</k>
  rule <k> (. => iterate(O, raiseInternal("TypeError", "cannot convert dictionary update sequence element #" +String Int2String(N) +String "to a sequence"))) ~>  list((ListItem(O) => .) _) ~> map(_) ~> makeDict(N, _) ...</k>
  rule <k> (list(ListItem(O) ListItem(O2)) => .) ~> list(_) ~> map(_ (. => O |-> O2)) ~> makeDict(N => N +Int 1, _) ...</k>
  rule <k> list(L) ~> list(_) ~> map(_) ~> makeDict(N, _) => raiseInternal("ValueError", "dictionary update sequence element #" +String Int2String(N) +String " has length " +String Int2String(lengthList L) +String "; 2 is required") ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> makeDict(_, _) ...</k>

endmodule
