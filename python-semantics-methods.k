require "python-semantics-common.k"

module PYTHON-SEMANTICS-METHODS
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "method" "(" Expression "," Expression ")" [strict]

  rule invokeBuiltin(obj("get_builtin_method",_), ListItem(Self:Object) ListItem(Instance:Object) ListItem(Owner:Object), .) => describe(Self, Instance, Owner, "get_function")
  rule invokeBuiltin(obj("get_function",_), ListItem(Self:Object) ListItem(Instance:Object) ListItem(Owner:Object), .) => describe(Self, Instance, Owner, "get_function")
  rule doDescribe(Self, .Obj, O, "get_function") => Self
  rule doDescribe(Self, O:Object, _, "get_function") => method(Self, O)

  rule method(obj(FuncId,_), obj(SelfId,_)) => immutable("__func__" |-> ref(FuncId) "__self__" |-> ref(SelfId), ref("method"))

  //can't use descriptors because method descriptors use it
  rule [call]: obj(N:Int,ObjState:Bag) (Args:K) => (getmember(obj(N,ObjState), "__call__", false, false, false) (obj(N,ObjState), Args)) -> (raiseInternal("TypeError", "object is not callable"))

  rule invokeBuiltin(obj("call_method",_), ListItem(obj(N, <oattrs>... "__func__" |-> Func "__self__" |-> Self ...</oattrs>)) L:List, M:Map) => doCall(Func, ListItem(Self) L, M)

  rule doCall((O:Object => .), _, _) ~> (. => O (.Arguments))
  rule doCall(., _ (ListItem(K:K) => .), .) ~> _:Object (Args:K => (K , Args))
  rule doCall(., _, _ (S:String |-> K => .)) ~> _:Object (Args:K => (String2Id(S) = K, Args))
  rule doCall(., ., .) => .

  rule invokeBuiltin(obj("call_builtin_function",_), ListItem(Func) L:List, M:Map) => doCall(Func, L, M)

  rule invokeBuiltin(obj("new_classmethod",_), ListItem(Class) ListItem(Method), .) => newHelper(Class, ref("classmethod"), .) ~> mutable("__func__" |-> ref("None"), Class)
  rule invokeBuiltin(obj("init_classmethod",_), ListItem(Self) ListItem(Method), .) => setref(id(Self), "__func__", Method) ~> ref("None")
  rule invokeBuiltin(obj("get_classmethod",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => describe(Self, Instance, Owner, "get_classmethod")
  rule doDescribe(Self, _, Owner, "get_classmethod") => method(getref(Self, "__func__"), Owner)

  rule invokeBuiltin(obj("new_staticmethod",_), ListItem(Class) ListItem(Method), .) => newHelper(Class, ref("staticmethod"), .) ~> mutable("__func__" |-> ref("None"), Class)
  rule invokeBuiltin(obj("init_staticmethod",_), ListItem(Self) ListItem(Method), .) => setref(id(Self), "__func__", Method) ~> ref("None")
  rule invokeBuiltin(obj("get_staticmethod",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => getref(Self, "__func__")

endmodule
