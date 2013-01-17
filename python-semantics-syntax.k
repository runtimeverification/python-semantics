require "python-syntax.k"

module PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax Value ::= NUMBER
                 | STRING
                 | KList
                 | KMap

  syntax Object ::= "obj" "(" ObjId "," Bag ")"

  syntax ObjId ::= Int
                   | String

  syntax Expression ::= ObjRef
                | Null
                | Undefined
                | KList
                | KMap

  syntax Null ::= ".Obj"

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
  syntax KList ::= "list" "(" List ")"
  syntax KMap ::= "map" "(" Map ")"

endmodule
