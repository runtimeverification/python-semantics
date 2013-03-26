require "python-semantics-common.k"

module PYTHON-SEMANTICS-ATTRIBUTE-REF
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= mapLookup(Expression, Expression) [strict]
                  | mapInsert(Expression, Expression, Expression) [strict]
                  | basesLookup(Expression, Expression) [strict]
                  | basesLookup(List, Expression) [strict(2), klabel('basesLookup2)]
                  | descriptor(Expression, Expression, Expression, Test) [strict]
                  | checkData(Expression, Expression) [strict]
                  | checkDataSet(Expression, Expression, Expression) [strict]

  rule [attribute]: O:Object . X:Id => ref("getattr")(O, Id2String(X), .Arguments)

  rule invokeBuiltin("getattr", _) => try:
                                     (try:
                                       return getmember(String2Id("object"), "__getattribute__", true, false, true)(String2Id("name"))
                                     except ref("AttributeError") :
                                       (if hasmember(String2Id("object"), "__getattr__") :
                                         return getmember(String2Id("object"), "__getattr__", true, false, true) (String2Id("name"))
                                       else:
                                         raise))
                                   except ref("AttributeError") :
                                     (if String2Id("default") ==Obj .Obj :
                                       raise
                                     else:
                                       return String2Id("default"))

  //rule invokeBuiltin(obj("hasattr",_), ListItem(O) ListItem(S), .) => try: (ref("getattr")(O, S, .Arguments) ; ~> ref("True")) except ref("AttributeError") : ref("False") else: pass

  rule invokeBuiltin("object.__getattribute__",_) => (if hasmember(String2Id("self"), String2Id("name")) :
                                                     String2Id("data"), .Expressions := getmember(String2Id("self"), String2Id("name"), false, false, true) newline
                                                     (if hasmember(String2Id("data"), "__set__") or hasmember(String2Id("data"), "__delete__") :
                                                       return descriptor(String2Id("data"), String2Id("self"), gettype(String2Id("self")), false)
                                                     else: pass)
                                                   else: pass) newline
                                                   String2Id("val"), .Expressions := mapLookup(String2Id("self"), String2Id("name")) newline
                                                   (if String2Id("val") =/=Obj .Obj :
                                                     return String2Id("val")
                                                   else: pass) newline
                                                   return getmember(String2Id("self"), String2Id("name"), true, false, true)
                      
  
  rule invokeBuiltin("type.__getattribute__",_) => (if hasmember(String2Id("self"), String2Id("name")) :
                                                     String2Id("data"), .Expressions := getmember(String2Id("self"), String2Id("name"), false, false, true) newline
                                                     (if hasmember(String2Id("data"), "__set__") or hasmember(String2Id("data"), "__delete__") :
                                                       return descriptor(String2Id("data"), String2Id("self"), gettype(String2Id("self")), false)
                                                      else: pass)
                                                   else: pass) newline
                                                   return getmember(String2Id("self"), String2Id("name"), true, true, true)
                                                 
  syntax Test ::= checkMember(Expression) [strict]
  rule hasmember(O:Object, O2:Object) => checkMember(getmember(O, O2, false, false, false)) -> false
  rule checkMember(.Obj) => .Obj
  rule checkMember(O:Object) => true

  rule getmember(O:Object, O2:Object, T:Bool, T2:Bool, true) => getmember(O, O2, T, T2, false) -> raiseInternal("AttributeError", "object has no attribute '" +String strvalue(O2) +String "'")
  rule getmember(O:Object, O2:Object, true, false, false) => descriptor(getmember(O, O2, false, false, false), O, gettype(O), false)
  rule getmember(O:Object, O2:Object, false, true, false) => basesLookup(getref(O, "__mro__"), O2) -> getmember(O, O2, false, false, false)
  rule getmember(O:Object, O2:Object, true, true, false) => descriptor(basesLookup(getref(O, "__mro__"), O2), O, gettype(O), true) -> getmember(O, O2, true, false, false)
  rule getmember(O:Object, O2:Object, false, false, false) => basesLookup(getref2(gettype(O), "__mro__"), O2)

  rule <k> mapLookup(obj(B,_), O) => try: K[O] except ref("KeyError") : .Obj else: pass ...</k>
       <object>
         <id>B</id>
         <oattrs>... "__dict__" |-> K ...</oattrs>
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
  rule basesLookup(ListItem(B) L:List, O) => mapLookup(B, O) -> basesLookup(L, O)
  rule basesLookup(., _) => .Obj

  rule descriptor(.Obj,_,_,_) => .Obj

  //TODO: add super
  rule descriptor(O:Object, O2:Object, _, true) => (getmember(O, "__get__", false, false, false) ( O , ref("None") , O2, .Arguments)) -> O
  rule <k> descriptor(O:Object, O2:Object, Type:Object, false) => (getmember(O, "__get__", false, false, false) ( O , O2 , Type, .Arguments )) -> O ...</k>
       <symbols>... "None" |-> NoneId ...</symbols> when id(O2) =/=K NoneId
  rule <k> descriptor(O:Object, O2:Object, Type:Object, false) => (getmember(O, "__get__", false, false, false) (O, O2, O2, .Arguments)) -> O ...</k>
       <symbols>... "None" |-> NoneId ...</symbols> when id(O2) ==K NoneId
 
  rule setmember(O:Object, Name:Object, Value:Object) => checkDataSet(getmember(O, Name, false, false, false), O, Value) -> mapInsert(O, Name, Value) -> raiseInternal("AttributeError", "object has no attribute '" +String strvalue(Name) +String "'")

  rule checkDataSet(O:Object, Instance, Value) => getmember(O, "__set__", false, false, false) (O, Instance, Value, .Arguments) -> .Obj
  rule checkDataSet(.Obj, _, _) => .Obj

  rule <k> mapInsert(obj(B,_), Name, Value) => Dict [Name] , .Expressions := Value ~> ref("None") ...</k>
       <object>
         <id> B </id>
         <oattrs>... "__dict__" |-> Dict ...</oattrs>
       </object>

  rule <k> mapInsert(obj(B,_), _, _) => .Obj ...</k>
       <object>...
         <id> B </id>
         <oattrs> Env:Map </oattrs>
       ...</object> when notBool("__dict__" in keys(Env))

  rule <k> mapInsert(obj(B,_), _, _) => raiseInternal("TypeError", "can't set attributes of built-in/extension type") ...</k>
       <object>...
         <id> B </id>
         <oattrs>... "__dict__" |-> _ ...</oattrs>
         <oenv> _ </oenv>
       ...</object>

endmodule
