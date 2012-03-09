module PYTHON-SEMANTICS-SYNTAX
  imports PYTHON-SYNTAX

  syntax Value ::= NUMBER
                 | STRING
                 | #Float "+" #Float "j"
                 | KList
                 | KMap

  macro F:#Float j = 0.0 + F j

  syntax Object ::= "obj" "(" Builtin "," Bag ")"

  syntax Builtin ::= #Nat
                   | #String

  syntax NAME ::= ObjRef
                | Null

  syntax Null ::= ".Obj"

  syntax Undefined ::= "undefined" "(" #String ")"

  syntax KResult ::= Object
                   | #Bool
                   | KList
                   | KMap
                   | Null
                   | Undefined

  syntax Test ::= #Bool
  syntax ObjRef ::= Object
  syntax ListRef ::= KList
  syntax KList ::= "list" "(" List ")"
  syntax KMap ::= "map" "(" Map ")"
end module
