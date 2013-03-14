require "python-semantics-common.k"

module PYTHON-SEMANTICS-METHODS
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "method" "(" Expression "," Expression ")" [strict]

  syntax #Id ::= "self" | "instance" | "owner"
  rule invokeBuiltin("builtin-method.__get__",_) => return describe(self, instance, owner, "function.__get__")
  //rule invokeBuiltin(obj("get_function",_), ListItem(Self:Object) ListItem(Instance:Object) ListItem(Owner:Object), .) => describe(Self, Instance, Owner, "get_function")
  rule doDescribe(Self, .Obj, O, "function.__get__") => Self
  rule doDescribe(Self, O:Object, _, "function.__get__") => method(Self, O)

  rule method(obj(FuncId,_), obj(SelfId,_)) => immutable("__func__" |-> ref(FuncId) "__self__" |-> ref(SelfId), ref("method"))

  // iter() calls methods, and * x and ** x call iter(), so we can't call * x and ** x in this function. Fortunately, we know that args is a tuple and kwargs is a dict.
  rule invokeBuiltin("method.__call__", "self" |-> Self:Object "args" |-> Args:Object "kwargs" |-> KwArgs:Object) => return doCall(getref(Self, "__func__"), ListItem(getref(Self, "__self__")) listvalue(Args), mapvalue(KwArgs))

  rule doCall((O:Object => .), _, _) ~> (. => O (.Arguments))
  rule doCall(., _ (ListItem(K:K) => .), .) ~> _:Object (Args:K => (K , Args))
  rule doCall(., _, _ (S:String |-> K => .)) ~> _:Object (Args:K => (String2Id(S) = K, Args))
  rule <k> doCall(., _, _ (ref(B) |-> K => .)) ~> _:Object (Args:K => (String2Id(S) = K, Args)) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> S:String ...</oattrs>
       ...</object>
  rule doCall(., ., .) => .

  //rule invokeBuiltin(obj("call_builtin_function",_), ListItem(Func) L:List, M:Map) => doCall(Func, L, M)

  //rule invokeBuiltin(obj("new_classmethod",_), ListItem(Class) ListItem(Method), .) => newHelper(Class, ref("classmethod"), .) ~> mutable("__func__" |-> ref("None"), Class)
  //rule invokeBuiltin(obj("init_classmethod",_), ListItem(Self) ListItem(Method), .) => setref(id(Self), "__func__", Method) ~> ref("None")
  //rule invokeBuiltin(obj("get_classmethod",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => describe(Self, Instance, Owner, "get_classmethod")
  rule doDescribe(Self, _, Owner, "get_classmethod") => method(getref(Self, "__func__"), Owner)

  //rule invokeBuiltin(obj("new_staticmethod",_), ListItem(Class) ListItem(Method), .) => newHelper(Class, ref("staticmethod"), .) ~> mutable("__func__" |-> ref("None"), Class)
  //rule invokeBuiltin(obj("init_staticmethod",_), ListItem(Self) ListItem(Method), .) => setref(id(Self), "__func__", Method) ~> ref("None")
  //rule invokeBuiltin(obj("get_staticmethod",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => getref(Self, "__func__")

endmodule
