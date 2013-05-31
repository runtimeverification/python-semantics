require "python-semantics-common.k"

module PYTHON-SEMANTICS-ASSIGNMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "bindList" "(" List "," Object "," Bool ")"
             | "unbindList" "(" List ")"

  rule (. => bind(X:Id, ref(B:ObjId))) ~> ((X)::Target = Ts:AssignTargets => Ts) = obj(B,_)
  rule (. => bindList(Listify(Ts2), O, false)) ~> (tuple(Ts2:Targets) = Ts:AssignTargets => Ts) = O:Object
  rule (. => bindList(Listify(Ts2), O, false)) ~> ([ Ts2 ] = Ts:AssignTargets => Ts) = O
  rule (. => 'Expr(ref("setattr")(O, Id2String(X), O2))) ~> (O:Object . X:Id = Ts:AssignTargets => Ts) = O2:Object
  rule (. => 'Expr((getmember(O, "__setitem__", true, false, false) -> raiseInternal("TypeError", "object does not support item assignment")) (Key:Object, Value:Object))) ~> (O:Object [ Key:Object ] = Ts:AssignTargets => Ts) = Value
  rule .AssignTargets = _ => .

  context HOLE . _:Id = _ = K:Exp when isKResult(K)
  context HOLE [ _ ] = _ = K:Exp when isKResult(K)
  context K [ HOLE ] = _ = K2:Exp when isKResult(K) andBool isKResult(K2)

  rule (. => unbind(X:Id)) ~> del (X , Ts:NeTargets => Ts)
  rule (. => unbindList(Listify(Ts2))) ~> del (tuple(Ts2) , Ts => Ts)
  rule (. => unbindList(Listify(Ts2))) ~> del ([ Ts2 ] , Ts => Ts)
  rule (. => 'Expr(getmember(O, "__delattr__", true, false, true) (Id2String(X)))) ~> del (O:Object . X:Id , Ts => Ts)
  rule (. => 'Expr((getmember(O, "__delitem__", true, false, false) -> raiseInternal("TypeError", "object does not support item deletion")) (Key)))  ~> del (O:Object [ Key:Object ] , Ts => Ts)
  rule del .NeTargets => .

  context del HOLE . _:Id , _
  context del HOLE [ _ ] , _
  context del K [ HOLE ] , _ when isKResult(K)

  rule (. => iterate(O, .)) ~> bindList(_, O, _)
  rule (. => T = O:Object) ~> list((ListItem(O) => .) _) ~> bindList((ListItem(T:Target) => .) _, _, _) when getKLabel T =/=KLabel 'Starred
  rule (. => T:Target = mutable(list(Refify(Idify(L))), ref("list"))) ~> list((L:List => .) L2:List) ~> bindList((ListItem(* T) => .) L3:List, _, (false => true)) when lengthList L2 ==Int lengthList L3
  rule list(.) ~> bindList(., _, _) => .
  rule list(ListItem(_) _) ~> bindList(., _, _) => raiseInternal("ValueError", "too many values to unpack")
  rule list(.) ~> bindList(ListItem(T) _, _, _) => raiseInternal("ValueError", "need more values to unpack") when getKLabel T =/=KLabel 'Starred

  rule (. => del (T ::Target)) ~> unbindList((ListItem(T) => .) _)
  rule unbindList(.) => .

endmodule
