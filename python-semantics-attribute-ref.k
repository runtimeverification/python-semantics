module PYTHON-SEMANTICS-ATTRIBUTE-REF
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "mapLookup" "(" Expression "," #String ")" [:strict(1):]
                  | "basesLookup" "(" Expression "," #String ")" [:strict(1):]
                  | "basesLookup" "(" ListRef "," #String ")" [:strict(1):]
                  | "descriptormatch" "(" Expression "," Expression "," Expression "," Test ")" [:strict:]
                  | "descriptorinvoke" "(" Expression "," Expression "," Expression "," Test ")" [:strict:]

  rule basesLookup(list(ListItem(B:Builtin) L:List), S:#String) => (basesLookup(ref(B), S) -> basesLookup(list(L), S))
  rule basesLookup(list(.List), _) => .Obj

  rule <k> O . X:#Id => getmember(O, #id "__getattribute__", true, false, true) (Id2String(X)) ...</k>

  rule <k> invokeBuiltin(obj("getattribute_object",_), ListItem(O) ListItem(O2:Object), .) => getmember(O, #id strvalue(O2), true, true, true) ...</k>
  rule <k> invokeBuiltin(obj("getattribute_module",_), ListItem(O) ListItem(O2), .) => getmember(O, #id strvalue(O2), false, true, true) ...</k>

  rule <k> getmember(O, X, T:#Bool, T2:#Bool, true) => getmember(O, X, T, T2, false) -> getmember(O, #id "__getattr__", true, false, false) (Id2String(X)) -> raiseInternal("AttributeError", "object has no attribute '" +String Id2String(X) +String "'") ...</k>
  rule <k> getmember(O, X, true, false, false) => descriptormatch(getmember(O, X, false, false, false), O, gettype(O), false) ...</k>
  rule <k> getmember(O, #id S, false, true, false) => mapLookup(O, S) -> getmember(O, #id S, false, false, false) ...</k>
  rule <k> getmember(O:Object , #id S, true, true, false) => descriptormatch(mapLookup(O, S), O, gettype(O), true) -> getmember(O, #id S, true, false, false) ...</k>
  rule <k> getmember(O, #id S, false, false, false) => basesLookup(gettype(O), S) ...</k>

  rule <k> mapLookup(obj(N:#Nat,_), S) => ref(B:Builtin) ...</k>
       <object>...
         <id>N</id>
         <oenv>... S |-> B ...</oenv>
       ...</object>

  rule mapLookup(obj(S,_), _) => .Obj

  rule <k> mapLookup(obj(N,_), S) => .Obj ...</k>
       <object>...
         <id>N</id>
         <oenv>Env:Map</oenv>
       ...</object> when notBool(S in keys(Env))

  rule basesLookup(obj(N,ObjState:Bag), S) => (mapLookup(obj(N,ObjState), S) -> basesLookup(getbases(obj(N,ObjState)), S))

  rule descriptormatch(.Obj,_,_,_) => .Obj

  //needs predicates to work without obj()
  //TODO: add super
  rule <k> descriptormatch(obj(B,ObjState), O, Type, T) => descriptorinvoke(obj(B,ObjState), O, Type, T) ...</k>
  rule <k> descriptorinvoke(obj(B,ObjState), O, _, true) => (getmember(obj(B,ObjState), #id "__get__", false, false, false) ( obj(B,ObjState) , #id "None" , O)) -> obj(B,ObjState) ...</k>
  rule <k> descriptorinvoke(obj(B,ObjState), O, Type:Object, false) => (getmember(obj(B,ObjState), #id "__get__", false, false, false) ( obj(B,ObjState) , O , Type )) -> obj(B,ObjState) ...</k>

end module
