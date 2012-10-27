require "python-semantics-common.k"

module PYTHON-SEMANTICS-ATTRIBUTE-REF
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "mapLookup" "(" Expression "," Expression ")" [strict]
                  | "basesLookup" "(" Expression "," Expression ")" [strict]
                  | "basesLookup" "(" List "," Expression ")" [strict(2)]
                  | "descriptor" "(" Expression "," Expression "," Expression "," Test ")" [strict]
                  | "checkData" "(" Expression "," Expression ")" [strict]

  rule O . X:Id => try: (getmember(O, "__getattribute__", true, false, true) (Id2String(X))) except ref("AttributeError") : (getmember(O, "__getattr__", true, false, false) (Id2String(X)) -> raise) else: pass

  rule invokeBuiltin(obj("getattribute_object",_), ListItem(O) ListItem(O2:Object), .) => checkData(getmember(O, O2, false, false, false), O) -> mapLookup(O, O2) -> getmember(O, O2, true, false, true)
  rule invokeBuiltin(obj("getattribute_type",_), ListItem(O) ListItem(O2), .) => checkData(getmember(O, O2, false, false, false), O) -> getmember(O, O2, true, true, true)

  rule checkData(O:Object, O2:Object) => test((getmember(O, "__set__", false, false, false) -> getmember(O, "__del__", false, false, false)) ==Obj .Obj, .Obj, descriptor(O, O2, gettype(O2), false))
  rule checkData(.Obj, _) => .Obj

  rule getmember(O:Object, O2, T:Bool, T2:Bool, true) => getmember(O, O2, T, T2, false) -> raiseInternal("AttributeError", "object has no attribute '" +String strvalue(O2) +String "'")
  rule getmember(O:Object, O2, true, false, false) => descriptor(getmember(O, O2, false, false, false), O, gettype(O), false)
  rule getmember(O:Object, O2, false, true, false) => basesLookup(getref(O, "__mro__"), O2) -> getmember(O, O2, false, false, false)
  rule getmember(O:Object, O2, true, true, false) => descriptor(basesLookup(getref(O, "__mro__"), O2), O, gettype(O), true) -> getmember(O, O2, true, false, false)
  rule getmember(O:Object, O2, false, false, false) => basesLookup(getref2(gettype(O), "__mro__"), O2)

  rule <k> mapLookup(obj(B,_), O) => try: ref(B2)[O] except ref("KeyError") : .Obj else: pass ...</k>
       <object>
         <id>B</id>
         <oattrs>... "__dict__" |-> B2 ...</oattrs>
       </object>

  rule <k> mapLookup(obj(B,_), O:Object) => .Obj ...</k>
       <object>
         <id>B</id>
         <oattrs>Attrs:Map</oattrs>
       </object> when notBool("__dict__" in keys(Attrs))

  rule <k> mapLookup(obj(B,_), O:Object) => K ...</k>
       <object>...
         <id>B</id>
         <oenv>... S |-> K ...</oenv>
       ...</object> when S ==String strvalue(O)

  rule <k> mapLookup(obj(B,_), O:Object) => .Obj ...</k>
       <object>...
         <id>B</id>
         <oenv> Env:Map </oenv>
       ...</object> when notBool(strvalue(O) in keys(Env))

  rule basesLookup(O:Object, O2:Object) => basesLookup(listvalue(O), O2)
  rule basesLookup(ListItem(B) L:List, O) => mapLookup(ref(B), O) -> basesLookup(L, O)
  rule basesLookup(., _) => .Obj

  rule descriptor(.Obj,_,_,_) => .Obj

  //TODO: add super
  rule descriptor(O:Object, O2:Object, _, true) => (getmember(O, "__get__", false, false, false) ( O , ref("None") , O2, .Arguments)) -> O
  rule <k> descriptor(O:Object, O2:Object, Type:Object, false) => (getmember(O, "__get__", false, false, false) ( O , O2 , Type, .Arguments )) -> O ...</k>
       <symbols>... "None" |-> None:Int ...</symbols> when id(O2) =/=K None
  rule <k> descriptor(O:Object, O2:Object, Type:Object, false) => (getmember(O, "__get__", false, false, false) (O, O2, O2, .Arguments)) -> O ...</k>
       <symbols>... "None" |-> None:Int ...</symbols> when id(O2) ==K None
 
endmodule
