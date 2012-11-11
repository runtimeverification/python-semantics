require "python-semantics-common.k"

module PYTHON-SEMANTICS-METHODS
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "method" "(" Expression "," Expression ")" [strict]

  rule invokeBuiltin(obj("get_builtin_method",_), ListItem(Self:Object) ListItem(Instance:Object) ListItem(Owner:Object), .) => describe(Self, Instance, Owner, "get_function")
  rule invokeBuiltin(obj("get_function",_), ListItem(Self:Object) ListItem(Instance:Object) ListItem(Owner:Object), .) => describe(Self, Instance, Owner, "get_function")
  rule doDescribe(Self, .Obj, O, "get_function") => O
  rule doDescribe(Self, O:Object, _, "get_function") => method(Self, O)

  syntax K ::= "triple" "(" K "," K "," K ")"

  rule <k> method(obj(FuncId,_), obj(SelfId,_)) => ref(N:Nat) ...</k>
       <symbols>... "method" |-> N2:Nat ...</symbols>
       <literals> M (. => triple(FuncId, SelfId, N2) |-> N) </literals>
       <nextLoc>N => N +Int 1</nextLoc>
       (. =>
       <object>...
         <id>N</id>
         <oattrs> "__class__" |-> N2 "__func__" |-> FuncId "__self__" |-> SelfId </oattrs>
       ...</object>) when notBool(triple(FuncId, SelfId, N2) in keys M)

  rule <k> method(obj(FuncId,_), obj(SelfId,_)) => ref(N) ...</k>
       <literals>... triple(FuncId, SelfId, N2) |-> N ...</literals>
       <symbols>... "method" |-> N2:Nat ...</symbols>

  //can't use descriptors because method descriptors use it
  rule obj(N:Nat,ObjState:Bag) (Args:K) => (getmember(obj(N,ObjState), "__call__", false, false, false) (obj(N,ObjState), Args)) -> (raiseInternal("TypeError", "object is not callable"))

  rule <k> invokeBuiltin(obj("call_method",_), ListItem(obj(N, <oattrs>... "__func__" |-> FuncId:Builtin "__self__" |-> SelfId:Builtin ...</oattrs>)) L:List, M:Map) => doCall(ref(FuncId), ListItem(ref(SelfId)) L, M) ...</k>
       <symbols>... "None" |-> NoneId:Nat ...</symbols>

  rule doCall((O:Object => .), _, _) ~> (. => O (.Arguments))
  rule doCall(., _ (ListItem(K:K) => .), .) ~> _:Object (Args:K => (K , Args))
  rule doCall(., _, _ (S:String |-> K => .)) ~> _:Object (Args:K => (String2Id(S) = K, Args))
  rule doCall(., ., .) => .

  rule invokeBuiltin(obj("call_builtin_function",_), ListItem(obj(B:Builtin,<oattrs>... "__call__" |-> S:String ...</oattrs>)) L, M) => doCall(ref(S), L, M)

  rule <k> invokeBuiltin(obj("new_classmethod",_), ListItem(Class) ListItem(Method), .) => newHelper(Class, ref("classmethod"), .) ~> mutable("__func__" |-> None, Class) ...</k>
       <symbols>... "None" |-> None ...</symbols>
  rule invokeBuiltin(obj("init_classmethod",_), ListItem(Self) ListItem(Method), .) => setref(id(Self), "__func__", Method) ~> ref("None")
  rule invokeBuiltin(obj("get_classmethod",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => describe(Self, Instance, Owner, "get_classmethod")
  rule doDescribe(Self, _, Owner, "get_classmethod") => method(getref(Self, "__func__"), Owner)

  rule <k> invokeBuiltin(obj("new_staticmethod",_), ListItem(Class) ListItem(Method), .) => newHelper(Class, ref("staticmethod"), .) ~> mutable("__func__" |-> None, Class) ...</k>
       <symbols>... "None" |-> None ...</symbols>
  rule invokeBuiltin(obj("init_staticmethod",_), ListItem(Self) ListItem(Method), .) => setref(id(Self), "__func__", Method) ~> ref("None")
  rule invokeBuiltin(obj("get_staticmethod",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => getref(Self, "__func__")

endmodule
