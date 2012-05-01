module PYTHON-SEMANTICS-ASSIGNMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "bindList" "(" List "," Object "," Bool ")"
             | "unbindList" "(" List ")"

  rule (. => bind(X:Id, B:Builtin)) ~> (X , Ts:Targets => Ts) := obj(B,_)
  rule (. => bindList(Listify(Ts2), O, false)) ~> (tuple(Ts2:Targets) , Ts => Ts) := O:Object
  rule (. => bindList(Listify(Ts2), O, false)) ~> ([ Ts2 ] , Ts => Ts) := O
  rule (. => (getmember(O, String2Id("__setattr__"), true, false, true) (Id2String(X), O2) ;)) ~> ((O . X) , Ts => Ts) := O2:Object
  rule (. => (getmember(O, String2Id("__setitem__"), true, false, false) -> raiseInternal("TypeError", "object does not support item assignment")) (Key:Object, Value:Object, .Expressions) ;) ~> ((O [ Key ]) , Ts => Ts) := Value
  rule .List{","} := _ => .

  context (HOLE . _:Id) , _:Targets := K:K when 'isKResult(K)
  context (HOLE [ _:Expression ]) , _:Targets := K when 'isKResult(K)
  context (K [ HOLE ]) , _:Targets := K2:K when 'isKResult(K) andBool 'isKResult(K2)

  rule (. => unbind(X)) ~> del (X , Ts => Ts)
  rule (. => unbindList(Listify(Ts2))) ~> del (tuple(Ts2) , Ts => Ts)
  rule (. => unbindList(Listify(Ts2))) ~> del ([ Ts2 ] , Ts => Ts)
  rule (. => (getmember(O, String2Id("__delattr__"), true, false, true) (Id2String(X)) ;)) ~> del ((O . X) , Ts => Ts)
  rule (. => (getmember(O, String2Id("__delitem__"), true, false, false) -> raiseInternal("TypeError", "object does not support item deletion")) (Key, .Expressions) ;)  ~> del ((O [ Key ]) , Ts => Ts)
  rule del .List{","} => .

  context del ((HOLE . _:Id) , _:Targets)
  context del ((HOLE [ _:Expression ]) , _:Targets)
  context del ((K [ HOLE ]) , _:Targets) when 'isKResult(K)

  rule (. => iterate(O, .)) ~> bindList(_, O, _)
  rule (. => T, .Expressions := O) ~> list((ListItem(O) => .) _) ~> bindList((ListItem(T:Target) => .) _, _, _) when getKLabel T =/=KLabel '*_
  rule (. => T, .Expressions := mutable(list(Idify(L)), ref("list"))) ~> list((L:List => .) L2:List) ~> bindList((ListItem(* T) => .) L3:List, _, (false => true)) when lengthList L2 ==Int lengthList L3
  rule list(.) ~> bindList(., _, _) => .
  rule list(ListItem(_) _) ~> bindList(., _, _) => raiseInternal("ValueError", "too many values to unpack")
  rule list(.) ~> bindList(ListItem(T) _, _, _) => raiseInternal("ValueError", "need more values to unpack") when getKLabel T =/=KLabel '*_

  rule (. => del (T, .Expressions)) ~> unbindList((ListItem(T) => .) _)
  rule unbindList(.) => .

end module
