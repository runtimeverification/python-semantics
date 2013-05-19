require "python-semantics-common.k"

module PYTHON-SEMANTICS-ATTRIBUTE-REF
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= mapLookup(Exp, Exp) [strict]
                  | mapInsert(Exp, Exp, Exp) [strict]
                  | basesLookup(Exp, Exp) [strict]
                  | basesLookup(List, Exp) [strict(2), klabel('basesLookup2)]
                  | descriptor(Exp, Exp, Exp, Test) [strict]
                  | checkData(Exp, Exp) [strict]
                  | checkDataSet(Exp, Exp, Exp) [strict]
                  | getSuperclass(Exp) [strict]
                  | searchSuperclass(Exp, Exp) [strict]

  rule [attribute]: O:Object . X:Id => ref("getattr")(O, Id2String(X))

  rule invokeBuiltin(obj("getattr",_), ListItem(O) ListItem(S:Object), .) => try: (getmember(O, "__getattribute__", true, false, true) (S)) except ref("AttributeError") : (getmember(O, "__getattr__", true, false, false) (S) -> raise) else: pass
  rule invokeBuiltin(obj("getattr",_), ListItem(O:Object) ListItem(S:Object) ListItem(Default), .) => try: ref("getattr")(O, S) except ref("AttributeError") : Default else: pass
  rule invokeBuiltin(obj("hasattr",_), ListItem(O:Object) ListItem(S:Object), .) => try: (ref("getattr")(O, S) ; ~> ref("True")) except ref("AttributeError") : ref("False") else: pass

  rule invokeBuiltin(obj("getattribute_object",_), ListItem(O) ListItem(O2:Object), .) => checkData(getmember(O, O2, false, false, false), O) -> mapLookup(O, O2) -> getmember(O, O2, true, false, true)
  rule invokeBuiltin(obj("getattribute_type",_), ListItem(O) ListItem(O2), .) => checkData(getmember(O, O2, false, false, false), O) -> getmember(O, O2, true, true, true)
  rule invokeBuiltin(obj("super.__getattribute__",_), ListItem(Super) ListItem(Key), .) => descriptor(basesLookup(getSuperclass(Super), Key), getref(Super, "__self__"), getref(Super, "__self_class__"), false) -> ref("getattribute_object")(Super, Key)

  rule checkData(O:Object, O2:Object) => test((getmember(O, "__set__", false, false, false) -> getmember(O, "__delete__", false, false, false)) ==Obj .Obj, .Obj, descriptor(O, O2, gettype(O2), false))
  rule checkData(.Obj, _) => .Obj

  rule getSuperclass(Super) => searchSuperclass(getref(Super, "__thisclass__"), getattr2(getref2(getref(Super, "__self_class__"), "__mro__"), "__value__"))
  rule searchSuperclass(ThisClass, list(ListItem(ref(N)) ListItem(K) L:List)) => getref(K, "__mro__") when id(ThisClass) ==K N
  rule searchSuperclass(ThisClass, list((ListItem(ref(N)) => .) ListItem(_) L:List)) when id(ThisClass) =/=K N
  rule searchSuperclass(ThisClass, list(ListItem(_))) => tuple(.Exps)

  rule getmember(O:Object, O2, T:Bool, T2:Bool, true) => getmember(O, O2, T, T2, false) -> raiseInternal("AttributeError", "object has no attribute '" +String strvalue(O2) +String "'")
  rule getmember(O:Object, O2, true, false, false) => descriptor(getmember(O, O2, false, false, false), O, gettype(O), false)
  rule getmember(O:Object, O2, false, true, false) => basesLookup(getref(O, "__mro__"), O2) -> getmember(O, O2, false, false, false)
  rule getmember(O:Object, O2, true, true, false) => descriptor(basesLookup(getref(O, "__mro__"), O2), O, gettype(O), true) -> getmember(O, O2, true, false, false)
  rule getmember(O:Object, O2, false, false, false) => basesLookup(getref2(gettype(O), "__mro__"), O2)

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

  rule descriptor(O:Object, O2:Object, _, true) => (getmember(O, "__get__", false, false, false) ( O , ref("None") , O2)) -> O
  rule <k> descriptor(O:Object, O2:Object, Type:Object, false) => (getmember(O, "__get__", false, false, false) ( O , O2 , Type )) -> O ...</k>
       <symbols>... "None" |-> NoneId:Int ...</symbols> when id(O2) =/=K NoneId
  rule <k> descriptor(O:Object, O2:Object, Type:Object, false) => (getmember(O, "__get__", false, false, false) (O, O2, O2)) -> O ...</k>
       <symbols>... "None" |-> NoneId:Int ...</symbols> when id(O2) ==K NoneId
 
  rule setmember(O:Object, Name:Object, Value:Object) => checkDataSet(getmember(O, Name, false, false, false), O, Value) -> mapInsert(O, Name, Value) -> raiseInternal("AttributeError", "object has no attribute '" +String strvalue(Name) +String "'")

  rule checkDataSet(O:Object, Instance:Object, Value:Object) => getmember(O, "__set__", false, false, false) (O, Instance, Value) -> .Obj
  rule checkDataSet(.Obj, _, _) => .Obj

  rule <k> mapInsert(obj(B,_), Name, Value) => Dict [Name]  = Value:Exp ~> ref("None") ...</k>
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
