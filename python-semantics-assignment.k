module PYTHON-SEMANTICS-ASSIGNMENT
  imports PYTHON-SEMANTICS-COMMON

  rule <k> (. => bind(X:#Id, B:Builtin)) ~> (X , Ts:Targets => Ts) := obj(B,_) ...</k>
  rule <k> .List{","} := _ => . ...</k>

  rule <k> (. => unbind(X)) ~> del (X , Ts => Ts) ...</k>
  rule <k> del .List{","} => . ...</k>

end module
