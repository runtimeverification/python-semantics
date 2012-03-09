module PYTHON-SEMANTICS-METHODS
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "method" "(" Expression "," Expression "," Expression ")" [:strict:]

  rule <k> invokeBuiltin(obj("get_builtin_method",_), ListItem(Self:Object) ListItem(Instance:Object) ListItem(Owner:Object), .) => method(Self, Instance, Owner) ...</k>

  rule <k> method(obj(FuncId,_), obj(SelfId,_), _) => ref(N:#Nat) ...</k>
       <symbols>... "method" |-> N2:#Nat "None" |-> NoneId:#Nat...</symbols>
       <nextLoc>N => N +Int 1</nextLoc>
       (. =>
       <object>...
         <id>N</id>
         <oattrs> "__class__" |-> N2 "__func__" |-> FuncId "__self__" |-> SelfId </oattrs>
       ...</object>) when SelfId =/=Bool NoneId

  rule <k> method(O:Object, obj(NoneId,_), _) => O ...</k>
       <symbols>... "None" |-> NoneId ...</symbols>

  //can't use descriptors because method descriptors use it
  rule <k> obj(N,ObjState:Bag) (Args:K) => (getmember(obj(N,ObjState), #id "__call__", false, false, false) (obj(N,ObjState), Args)) -> (raiseInternal("TypeError", "object is not callable")) ...</k>

  //TODO: MRO
  rule <k> invokeBuiltin(obj("call_method",_), ListItem(obj(N, <oattrs>... "__func__" |-> FuncId:Builtin "__self__" |-> SelfId:Builtin ...</oattrs>)) L:List, M:Map) => doCall(ref(FuncId), ListItem(ref(SelfId)) L, M) ...</k>
       <symbols>... "None" |-> NoneId:#Nat ...</symbols>

  rule <k> doCall((O => .), _, _) ~> (. => O ()) ...</k>
  rule <k> doCall(., _ (ListItem(K:K) => .), .) ~> _:Object (Args:K => (K , Args)) ...</k>
  rule <k> doCall(., _, _ (X:#Id |-> K => .)) ~> _:Object (Args:K => (X = K, Args)) ...</k>
  rule <k> doCall(., ., .) => . ...</k>

  rule <k> invokeBuiltin(obj("call_builtin_function",_), ListItem(obj(B:Builtin,<oattrs>... "__call__" |-> S:#String ...</oattrs>)) L, M) => doCall(ref(S), L, M) ...</k>

end module
