require "python-semantics-literals.k"

module PYTHON-SEMANTICS-DICTS
  imports PYTHON-SEMANTICS-LITERALS

  rule invokeBuiltin(obj("keys_dict",_), ListItem(obj(B:ObjId,_)), .) => mutable("_mapping" |-> ref(B), ref("dict_keys"))

  rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(_, <oattrs>... "_mapping" |-> ref(B) ...</oattrs>)), .) => mutable("_mapping" |-> ref(B) "__revision__" |-> N:Int "__order__" |-> list(sorted(DeSetify(keys M))) "__index__" |-> 0 "__index2__" |-> 0, ref("iterator")) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> N "__value__" |-> map(M:Map) ...</oattrs>
       ...</object>

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B2,_)), .) => raiseInternal("RuntimeError", "dictionary changed size during iteration") ...</k>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev1 "_mapping" |-> ref(B:ObjId) ...</oattrs>
       ...</object>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev2:Int ...</oattrs>
       ...</object> when Rev1 =/=Int Rev2

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B2,_)), .) => raise ref("StopIteration") ...</k>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev "__order__" |-> list(L) "__index__" |-> (Idx) "_mapping" |-> ref(B:ObjId) ...</oattrs>
       ...</object>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev ...</oattrs>
       ...</object> when Idx ==Int lengthList L

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev "__order__" |-> list(L) "__index__" |-> (Idx => Idx +Int 1) "__index2__" |-> (Idx2:Int => 0) "_mapping" |-> ref(B2:ObjId) ...</oattrs>
       ...</object>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev "__value__" |-> map(M) ...</oattrs>
       ...</object> when Idx =/=Int lengthList L andBool Idx2 ==Int lengthList getl(M:Map(get(L, Idx))) [structural]

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => key(get(getl(M:Map(get(L:List, Idx))), Idx2)) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__revision__" |-> Rev "__order__" |-> list(L) "__index__" |-> Idx "__index2__" |-> (Idx2:Int => Idx2 +Int 1) "_mapping" |-> ref(B2:ObjId) ...</oattrs>
       ...</object>
       <object>...
         <id>B2</id>
         <oattrs>... "__revision__" |-> Rev "__value__" |-> map(M) ...</oattrs>
       ...</object> when Idx =/=Int lengthList L andBool Idx2 =/=Int lengthList getl(M:Map(get(L, Idx)))

  rule invokeBuiltin(obj("iter_dict",_), ListItem(O), .) => ((O . String2Id("keys")) (.Arguments) . String2Id("__iter__")) (.Arguments)

  rule invokeBuiltin(obj("len_dict",_), ListItem(O), .) => lengthMap mapvalue(O)

  rule invokeBuiltin(obj("getitem_dict",_), ListItem(obj(B,_)) ListItem(Key:Object), .) => ref("hash")(Key) ~> tableLookup(B, 0, Key)
  rule (O:Object => .) ~> tableLookup(_,(_ => intvalue(O)),_)
  rule (O:Object => .) ~> tableLookup(_,(_ => intvalue(O)),_) ;

  rule invokeBuiltin(obj("setitem_dict",_), ListItem(O) ListItem(Key) ListItem(Value:Object), .) => processDict(O, Key |-> Value) ; ~> ref("None") 

  rule invokeBuiltin(obj("delitem_dict",_), ListItem(obj(B,_)) ListItem(Key:Object), .) => ref("hash")(Key) ~> tableDelete(B, 0, Key) ~> ref("None")
  rule (O:Object => .) ~> tableDelete(_,(_ => intvalue(O)),_)

  syntax K ::= makeDict(Int, Exp) [strict(2)]

  rule invokeBuiltin(obj("new_dict",_), ListItem(O) _, .) => newHelper(O, ref("dict"), .) ~> {.KeyData}
  rule invokeBuiltin(obj("init_dict",_), ListItem(_:Object), .) => ref("None")
  rule invokeBuiltin(obj("init_dict",_), ListItem(O) ListItem(O2:Object), .) => mapping(O2, .Obj) -> iterate(O2, .) ~> makeDict(0, O)

  rule (. => O[Key:K] = Value:Exp) ~> map((Key |-> Value => .) _) ~> makeDict(_, O) 
  rule map(.) ~> makeDict(_, O) => ref("None")

  rule <k> list(_) ~> (. => map(.)) ~> makeDict(_, _) ...</k>
  rule <k> (. => iterate(O, raiseInternal("TypeError", "cannot convert dictionary update sequence element #" +String Int2String(N) +String "to a sequence"))) ~>  list((ListItem(O) => .) _) ~> map(_) ~> makeDict(N, _) ...</k>
  rule <k> (list(ListItem(O) ListItem(O2)) => .) ~> list(_) ~> map(_ (. => O |-> O2)) ~> makeDict(N => N +Int 1, _) ...</k>
  rule <k> list(L) ~> list(_) ~> map(_) ~> makeDict(N, _) => raiseInternal("ValueError", "dictionary update sequence element #" +String Int2String(N) +String " has length " +String Int2String(lengthList L) +String "; 2 is required") ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> makeDict(_, _) ...</k>

  rule invokeBuiltin(obj("eq_dict",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "dict", "dict", equalDict(O, O2))

  syntax ObjRef ::= equalDict(Exp, Exp) [strict]
  rule equalDict(O:Object, O2) => bool(lengthList DeSetify(keys(mapvalue(O))) ==Int lengthList DeSetify(keys(mapvalue(O2)))) and equalDict(mapvalue(O), O2)
  syntax ObjRef ::= equalDict(Map, Exp) [strict(2)]
  rule equalDict(Key |-> Value M:Map, Dict) => Key in Dict and Dict[Key] == Value and equalDict(M, Dict)
  rule equalDict(.Map, _) => ref("True")

  rule invokeBuiltin(obj("contains_dict",_), ListItem(Dict) ListItem(Key:Object), .) => try: (ref("hash")(Key) ~> tableLookup(id(Dict), 0, Key) ; ~> ref("True")) except ref("KeyError"): ref("False") else: pass

endmodule
