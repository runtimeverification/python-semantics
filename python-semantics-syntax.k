require "python-syntax.k"

module PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax Value ::= NUMBER
                 | STRING
                 | KList
                 | KMap

  syntax Object ::= "obj" "(" Builtin "," Bag ")"

  syntax Builtin ::= Int
                   | String

  syntax Expression ::= ObjRef
                | Null
                | Undefined
                | Builtin
                | KList
                | KMap

  syntax Null ::= ".Obj"

  syntax Undefined ::= "undefined" "(" String ")"

  syntax KResult ::= Object
                   | Bool
                   | Null
                   | Undefined
                   | KList
                   | KMap

  syntax Statement ::= Expression

  syntax Test ::= Bool
  syntax ObjRef ::= Object
  syntax KList ::= "list" "(" List ")"
  syntax KMap ::= "map" "(" Map ")"

endmodule
