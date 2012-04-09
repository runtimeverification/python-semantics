module PYTHON-SEMANTICS-ATTRIBUTE-REF
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "mapLookup" "(" Expression "," #String ")" [:strict(1):]
                  | "basesLookup" "(" Expression "," #String ")" [:strict(1):]
                  | "basesLookup" "(" ListRef "," #String ")" [:strict(1):]
                  | "descriptor" "(" Expression "," Expression "," Expression "," Test ")" [:strict:]

  rule basesLookup(list(ListItem(B:Builtin) L:List), S:#String) => (basesLookup(ref(B), S) -> basesLookup(list(L), S))
  rule basesLookup(list(.List), _) => .Obj

  rule O . X:#Id => try: (getmember(O, #id "__getattribute__", true, false, true) (Id2String(X))) except ref("AttributeError") : (getmember(O, #id "__getattr__", true, false, false) (Id2String(X)) -> raise) else: pass

  rule invokeBuiltin(obj("getattribute_object",_), ListItem(O) ListItem(O2:Object), .) => getmember(O, #id strvalue(O2), true, true, true)
  rule invokeBuiltin(obj("getattribute_module",_), ListItem(O) ListItem(O2), .) => getmember(O, #id strvalue(O2), true, true, false) -> try: (O . #id "__dict__" [ O2 ]) except ref("KeyError") : (setx(.Obj) ~> raiseInternal("AttributeError", "object has no attribute '" +String  strvalue(O2) +String "'")) else: pass

  rule getmember(O, X, T:#Bool, T2:#Bool, true) => getmember(O, X, T, T2, false) -> raiseInternal("AttributeError", "object has no attribute '" +String Id2String(X) +String "'")
  rule getmember(O, X, true, false, false) => descriptor(getmember(O, X, false, false, false), O, gettype(O), false)
  rule getmember(O, #id S, false, true, false) => mapLookup(O, S) -> getmember(O, #id S, false, false, false)
  rule getmember(O:Object , #id S, true, true, false) => descriptor(mapLookup(O, S), O, gettype(O), true) -> getmember(O, #id S, true, false, false)
  rule getmember(O, #id S, false, false, false) => basesLookup(gettype(O), S)

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
  rule descriptor(O, O2, _, true) => (getmember(O, #id "__get__", false, false, false) ( O , #id "None" , O2)) -> O

end module
