require "python-syntax.k"

module PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax Value ::= NUMBER
                 | STRING

  syntax Object ::= obj(ObjId, Bag)
  syntax ObjId ::= Int | String

  syntax Exp ::= ObjRef
                | Null

  syntax Null ::= ".Obj"

  rule isKResult(obj(_,_)) => true
  rule isKResult(true) => true
  rule isKResult(false) => true
  rule isKResult(.Obj) => true
  rule isKResult(list(_)) => true
  rule isKResult(map(_)) => true

  syntax Stmt ::= Exp

  syntax Test ::= Bool
  syntax ObjRef ::= Object
  syntax K ::= "list" "(" List ")"
  syntax K ::= "map" "(" Map ")"

  rule isValue(list(_)) => true
  rule isExp(list(_)) => true
  rule isValue(map(_)) => true
  rule isExp(map(_)) => true

endmodule
