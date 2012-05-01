module PYTHON-SEMANTICS-OBJECTS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax ObjRef ::= "init" "(" Expression "," Expression "," List "," Map ")" [:strict(1 2):] 

  rule <k> invokeBuiltin(obj("call_type",_), ListItem(Type:Object) L:List, M:Map) => init(doCall(Type . String2Id("__new__"), ListItem(Type) L, M), Type, L, M) ...</k>

  rule <k> init(O:Object, Type, L, M) => test(istype(O, Type), (doCall(getmember(O, String2Id("__init__"), true, false, false), L, M) ; ~> ref(id(O))), O) ...</k>

  rule <k> invokeBuiltin(obj("new_object",_), ListItem(obj(B:Builtin,_)) _, _) => ref(N) ...</k>
       <nextLoc> N:Nat => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__class__" |-> B </oattrs>
       ...</object>)

  rule <k> invokeBuiltin(obj("init_object",_), _, _) => ref("None") ...</k>

  rule <k> invokeBuiltin(obj("eq_object",_), ListItem(O) ListItem(O2:Object), .) => test(plbool(O is O2), ref("True"), ref("NotImplemented")) ...</k>
  rule <k> invokeBuiltin(obj("ne_object",_), ListItem(O) ListItem(O2), .) => test(plbool(O is not O2), ref("True"), ref("NotImplemented")) ...</k>
 
  rule <k> invokeBuiltin(obj("new_raise",_), ListItem(O:Object) _, _) => raiseInternal("TypeError", "cannot create instances of this type") ...</k>

end module
