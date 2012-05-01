module PYTHON-SEMANTICS-ATTRIBUTE-REF
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "mapLookup" "(" Expression "," String ")" [:strict(1):]
                  | "basesLookup" "(" Expression "," String ")" [:strict(1):]
                  | "basesLookup" "(" ListRef "," String ")" [:strict(1):]
                  | "descriptor" "(" Expression "," Expression "," Expression "," Test ")" [:strict:]

  rule basesLookup(list(ListItem(B:Builtin) L:List), S:String) => (basesLookup(ref(B), S) -> basesLookup(list(L), S))
  rule basesLookup(list(.List), _) => .Obj

  rule O . X:Id => try: (getmember(O, String2Id("__getattribute__"), true, false, true) (Id2String(X))) except ref("AttributeError") : (getmember(O, String2Id("__getattr__"), true, false, false) (Id2String(X)) -> raise) else: pass

  rule invokeBuiltin(obj("getattribute_object",_), ListItem(O) ListItem(O2:Object), .) => getmember(O, String2Id(strvalue(O2)), true, true, true)
  rule invokeBuiltin(obj("getattribute_module",_), ListItem(O) ListItem(O2), .) => getmember(O, String2Id(strvalue(O2)), true, true, false) -> try: (O . String2Id("__dict__") [ O2 ]) except ref("KeyError") : (setx(.Obj) ~> raiseInternal("AttributeError", "object has no attribute '" +String  strvalue(O2) +String "'")) else: pass

  rule getmember(O, X, T:Bool, T2:Bool, true) => getmember(O, X, T, T2, false) -> raiseInternal("AttributeError", "object has no attribute '" +String Id2String(X) +String "'")
  rule getmember(O, X, true, false, false) => descriptor(getmember(O, X, false, false, false), O, gettype(O), false)
  rule getmember(O, X, false, true, false) => mapLookup(O, Id2String(X)) -> getmember(O, X, false, false, false)
  rule getmember(O:Object , X, true, true, false) => descriptor(mapLookup(O, Id2String(X)), O, gettype(O), true) -> getmember(O, X, true, false, false)
  rule getmember(O, X, false, false, false) => basesLookup(gettype(O), Id2String(X))

  rule <k> mapLookup(obj(B:Builtin,_), S) => ref(B2:Builtin) ...</k>
       <object>...
         <id>B</id>
         <oenv>... S |-> B2 ...</oenv>
       ...</object>

  rule <k> mapLookup(obj(B,_), S) => .Obj ...</k>
       <object>...
         <id>B</id>
         <oenv>Env:Map</oenv>
       ...</object> when notBool(S in keys(Env))

  rule basesLookup(O, S) => (mapLookup(O, S) -> basesLookup(getbases(O), S))

  rule descriptor(.Obj,_,_,_) => .Obj

  //TODO: add super
  rule descriptor(O, O2, _, true) => (getmember(O, String2Id("__get__"), false, false, false) ( O , ref("None") , O2)) -> O
  rule descriptor(O, O2, Type:Object, false) => (getmember(O, String2Id("__get__"), false, false, false) ( O , O2 , Type )) -> O

end module
