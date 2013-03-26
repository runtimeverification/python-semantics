require "python-syntax.k"

module PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax Value ::= NUMBER
                 | STRING

  syntax Object ::= "obj" "(" ObjId "," Bag ")"

  syntax ObjId ::= Int
                   | String

  syntax Expression ::= ObjRef
                | Null
                | Undefined
                | ObjId

  syntax Null ::= ".Obj"

  syntax ObjectPointer ::= Object | Null

  syntax Undefined ::= "undefined" "(" String ")"

  rule isKResult(obj(_,_)) => true
  rule isKResult(true) => true
  rule isKResult(false) => true
  rule isKResult(.Obj) => true
  rule isKResult(undefined(_)) => true
  rule isKResult(list(_)) => true
  rule isKResult(map(_)) => true

  syntax Statement ::= Expression

  syntax Test ::= Bool
  syntax ObjRef ::= Object
  syntax K ::= "list" "(" List ")"
  syntax K ::= "map" "(" Map ")"

  rule isValue(list(_)) => true
  rule isExpression(list(_)) => true
  rule isValue(map(_)) => true
  rule isExpression(map(_)) => true

endmodule
