require "python-semantics-literals.k"

module PYTHON-SEMANTICS-DICTS
  imports PYTHON-SEMANTICS-LITERALS

  //rule invokeBuiltin(obj("keys_dict",_), ListItem(obj(B:ObjId,_)), .) => mutable("_mapping" |-> ref(B), ref("dict_keys"))

  //rule <k> invokeBuiltin(obj("iter_dict_keys",_), ListItem(obj(_, <oattrs>... "_mapping" |-> ref(B) ...</oattrs>)), .) => mutable("_mapping" |-> ref(B) "__revision__" |-> N:Int "__order__" |-> list(sorted(DeSetify(keys M))) "__index__" |-> 0 "__index2__" |-> 0, ref("iterator")) ...</k>
  //     <object>...
  //       <id>B</id>
  //       <oattrs>... "__revision__" |-> N "__value__" |-> map(M:Map) ...</oattrs>
  //     ...</object>

  //rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B2,_)), .) => raiseInternal("RuntimeError", "dictionary changed size during iteration") ...</k>
  //     <object>...
  //       <id>B2</id>
  //       <oattrs>... "__revision__" |-> Rev1 "_mapping" |-> ref(B:ObjId) ...</oattrs>
  //     ...</object>
  //     <object>...
  //       <id>B</id>
  //       <oattrs>... "__revision__" |-> Rev2:Int ...</oattrs>
  //     ...</object> when Rev1 =/=Int Rev2

  //rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B2,_)), .) => raise ref("StopIteration") ...</k>
  //     <object>...
  //       <id>B2</id>
  //       <oattrs>... "__revision__" |-> Rev "__order__" |-> list(L) "__index__" |-> (Idx) "_mapping" |-> ref(B:ObjId) ...</oattrs>
  //     ...</object>
  //     <object>...
  //       <id>B</id>
  //       <oattrs>... "__revision__" |-> Rev ...</oattrs>
  //     ...</object> when Idx ==Int lengthList L

  //rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) ...</k>
  //     <object>...
  //       <id>B</id>
  //       <oattrs>... "__revision__" |-> Rev "__order__" |-> list(L) "__index__" |-> (Idx => Idx +Int 1) "__index2__" |-> (Idx2:Int => 0) "_mapping" |-> ref(B2:ObjId) ...</oattrs>
  //     ...</object>
  //     <object>...
  //       <id>B2</id>
  //       <oattrs>... "__revision__" |-> Rev "__value__" |-> map(M) ...</oattrs>
  //     ...</object> when Idx =/=Int lengthList L andBool Idx2 ==Int lengthList getl(M:Map(get(L, Idx))) [structural]

  //rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => key(get(getl(M:Map(get(L:List, Idx))), Idx2)) ...</k>
  //     <object>...
  //       <id>B</id>
  //       <oattrs>... "__revision__" |-> Rev "__order__" |-> list(L) "__index__" |-> Idx "__index2__" |-> (Idx2:Int => Idx2 +Int 1) "_mapping" |-> ref(B2:ObjId) ...</oattrs>
  //     ...</object>
  //     <object>...
  //       <id>B2</id>
  //       <oattrs>... "__revision__" |-> Rev "__value__" |-> map(M) ...</oattrs>
  //    ...</object> when Idx =/=Int lengthList L andBool Idx2 =/=Int lengthList getl(M:Map(get(L, Idx)))

  //rule invokeBuiltin(obj("iter_dict",_), ListItem(O), .) => ((O . String2Id("keys")) (.Arguments) . String2Id("__iter__")) (.Arguments)

  //rule invokeBuiltin(obj("len_dict",_), ListItem(O), .) => lengthMap mapvalue(O)

  //rule invokeBuiltin(obj("getitem_dict",_), ListItem(obj(B,_)) ListItem(Key:Object), .) => ref("hash")(Key) ~> tableLookup(B, 0, Key)
  rule (O:Object => .) ~> tableLookup(_,(_ => intvalue(O)),_)
  rule (O:Object => .) ~> tableLookup(_,(_ => intvalue(O)),_) ;

  //rule invokeBuiltin(obj("setitem_dict",_), ListItem(O) ListItem(Key) ListItem(Value:Object), .) => processDict(O, Key |-> Value) ; ~> ref("None") 

  //rule invokeBuiltin(obj("delitem_dict",_), ListItem(obj(B,_)) ListItem(Key), .) => ref("hash")(Key, .Arguments) ~> tableDelete(B, 0, Key) ~> ref("None")
  rule (O:Object => .) ~> tableDelete(_,(_ => intvalue(O)),_)

  syntax K ::= makeDict(Int, Expression) [strict(2)]

  syntax #Id ::= "cls"
  rule invokeBuiltin("dict.__new__") => newHelper(cls, ref("dict"), .) ~> return {.KeyData}
  rule invokeBuiltin("dict.__init__") => if String2Id("") =/=Obj .Obj :
                                           if hasmember(String2Id(""), "keys") :
                                             for String2Id("key") in getmember(String2Id(""), "keys", true, false, true) :
                                               self[String2Id("key"] := String2Id("") [ String2Id("key") ]
                                           else:
                                             for String2Id("tuple") in String2Id("") :
                                               (try:
                                                 String2Id("iter") := ref("iter")(String2Id("tuple")) newline
                                               except ref("TypeError") :
                                                 raiseInternal("TypeError", "cannot convert dictionary update sequence element to a sequence")) newline
                                               (try:
                                                 String2Id("key") := String2Id("iter") . __next__ (.Arguments) newline
                                                 String2Id("value") := String2Id("iter") . __next__ (.Arguments)
                                               except ref("StopIteration") :
                                                 raiseInternal("TypeError", "dictionary update sequence element has length less than 2; 2 is required")) newline
                                               self[String2Id("key")] := String2Id("value") newline
                                               try:
                                                 String2Id("iter") . __next__ (.Arguments) newline
                                                 raiseInternal("TypeError", "dictionary update sequence element has length greater than 2; 2 is required")
                                               except ref("StopIteration") : pass
                                         else: pass ~>
                                         for String2Id("key") in kwargs:
                                           self[String2Id("key"] := kwargs[String2Id("key"] ~>
                                         return ref("None")
                                          
  //rule invokeBuiltin(obj("eq_dict",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "dict", "dict", equalDict(O, O2))

  syntax ObjRef ::= equalDict(Expression, Expression) [strict]
  rule equalDict(O:Object, O2) => bool(lengthList DeSetify(keys(mapvalue(O))) ==Int lengthList DeSetify(keys(mapvalue(O2)))) and equalDict(mapvalue(O), O2)
  syntax ObjRef ::= equalDict(Map, Expression) [strict(2)]
  rule equalDict(Key |-> Value M, Dict) => Key in Dict and Dict[Key] == Value and equalDict(M, Dict)
  rule equalDict(.Map, _) => ref("True")

  //rule invokeBuiltin(obj("contains_dict",_), ListItem(Dict) ListItem(Key:Object), .) => try: (ref("hash")(Key) ~> tableLookup(id(Dict), 0, Key) ; ~> ref("True")) except ref("KeyError"): ref("False") else: pass

endmodule
