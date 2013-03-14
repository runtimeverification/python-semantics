require "python-semantics-common.k"

module PYTHON-SEMANTICS-OPS
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "coerceBinaryBase" "(" Exp "," Exp "," Exp "," Exp ")" [strict(1, 2)]
                  | "coerceBinary" "(" Exp "," Exp "," Exp "," Exp "," String ")" [strict(1, 2)]
                  | "coerceUnary" "(" Exp "," Exp "," String ")" [strict(1)]
                  | "coercion" "(" Exp ")" [strict]

  rule <k> coerceBinary(O:Object, O2:Object, X, RX, S:String) => coerceBinaryBase(O, O2, X, RX) -> (raiseInternal("TypeError", "unsupported operand type(s) for " +String S)) ...</k>

  rule <k> coerceBinaryBase(O:Object, O2:Object, X, RX) => test(hasbase(getbases(gettype(O2)), gettype(O)), coercion(getmember(O2, RX, true, false, false) (O)), .Obj) -> coercion(getmember(O, X, true, false, false) (O2)) -> coercion(getmember(O2, RX, true, false, false) (O)) ...</k>

  rule <k> coerceUnary(O:Object, X, S) => coercion(getmember(O, X, true, false, false) (.Arguments)) -> (raiseInternal("TypeError", "bad operand type for " +String S)) ...</k>

  rule <k> coercion(obj(N,ObjState:Bag)) => test(or((N ==Int NoneId), (N ==Int NotImplementedId)), .Obj, obj(N,ObjState)) ...</k>
       <symbols>... "None" |-> NoneId "NotImplemented" |-> NotImplementedId ...</symbols>
  rule coercion(.Obj) => .Obj

endmodule
