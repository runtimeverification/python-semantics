require "python-semantics-common.k"

module PYTHON-SEMANTICS-ASSIGNMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "bindList" "(" List "," Object "," Bool ")"
             | "unbindList" "(" List ")"

  rule (. => bind(X:Id, ref(B:ObjId))) ~> (X , Ts:Expressions => Ts) := obj(B,_)
  rule (. => bind(X:Id, .Obj)) ~> (X, Ts:Expressions => Ts) := .Obj
  rule (. => bindList(Listify(Ts2), O, false)) ~> (tuple(Ts2:Expressions) , Ts => Ts) := O:Object
  rule (. => bindList(Listify(Ts2), O, false)) ~> ([ Ts2 ] , Ts => Ts) := O
  rule (. => ref("setattr")(O, Id2String(X), O2) ;) ~> ((O:Object . X:Id) , Ts => Ts) := O2:Object
  rule (. => (getmember(O, "__setitem__", true, false, false) -> raiseInternal("TypeError", "object does not support item assignment")) (Key:Object, Value:Object, .Expressions) ;) ~> ((O:Object [ Key:Object ]) , Ts => Ts) := Value
  rule .Expressions := _ => .

  context ((HOLE . _:Id) , _) := K:K when isKResult(K)
  context ((HOLE [ _ ]) , _) := K when isKResult(K)
  context ((K [ HOLE ]) , _) := K2:K when isKResult(K) andBool isKResult(K2)

  rule (. => unbind(X:Id)) ~> del (X , Ts => Ts)
  rule (. => unbindList(Listify(Ts2))) ~> del (tuple(Ts2) , Ts => Ts)
  rule (. => unbindList(Listify(Ts2))) ~> del ([ Ts2 ] , Ts => Ts)
  rule (. => (getmember(O, "__delattr__", true, false, true) (Id2String(X)) ;)) ~> del ((O:Object . X:Id) , Ts => Ts)
  rule (. => (getmember(O, "__delitem__", true, false, false) -> raiseInternal("TypeError", "object does not support item deletion")) (Key, .Expressions) ;)  ~> del ((O:Object [ Key:Object ]) , Ts => Ts)
  rule del .Expressions => .

  context del ((HOLE . _:Id) , _)
  context del ((HOLE [ _ ]) , _)
  context del ((K [ HOLE ]) , _) when isKResult(K)

  rule (. => iterate(O, .)) ~> bindList(_, O, _)
  rule (. => T, .Expressions := O) ~> list((ListItem(O) => .) _) ~> bindList((ListItem(T:Expression) => .) _, _, _) when getKLabel T =/=KLabel '*_
  rule (. => T, .Expressions := mutable(list(Refify(Idify(L))), ref("list"))) ~> list((L:List => .) L2:List) ~> bindList((ListItem(* T) => .) L3:List, _, (false => true)) when lengthList L2 ==Int lengthList L3
  rule list(.) ~> bindList(., _, _) => .
  rule list(ListItem(_) _) ~> bindList(., _, _) => raiseInternal("ValueError", "too many values to unpack")
  rule list(.) ~> bindList(ListItem(T) _, _, _) => raiseInternal("ValueError", "need more values to unpack") when getKLabel T =/=KLabel '*_

  rule (. => del (T, .Expressions)) ~> unbindList((ListItem(T) => .) _)
  rule unbindList(.) => .

endmodule
