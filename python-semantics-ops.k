require "python-semantics-common.k"

module PYTHON-SEMANTICS-OPS
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "coerceBinaryBase" "(" Expression "," Expression "," Expression "," Expression ")" [strict(1, 2)]
                  | "coerceBinary" "(" Expression "," Expression "," Expression "," Expression "," String ")" [strict(1, 2)]
                  | "coerceUnary" "(" Expression "," Expression "," String ")" [strict(1)]
                  | "coercion" "(" Expression ")" [strict]

  rule <k> coerceBinary(O:Object, O2:Object, X, RX, S:String) => coerceBinaryBase(O, O2, X, RX) -> (raiseInternal("TypeError", "unsupported operand type(s) for " +String S)) ...</k>

  rule <k> coerceBinaryBase(O, O2, X, RX) => test(hasbase(getbases(gettype(O2)), gettype(O)), coercion(getmember(O2, RX, true, false, false) (O, .Arguments)), .Obj) -> coercion(getmember(O, X, true, false, false) (O2, .Arguments)) -> coercion(getmember(O2, RX, true, false, false) (O, .Arguments)) ...</k>

  rule <k> coerceUnary(O, X, S) => coercion(getmember(O, X, true, false, false) (.Arguments)) -> (raiseInternal("TypeError", "bad operand type for " +String S)) ...</k>

  rule <k> coercion(obj(N:Nat,ObjState:Bag)) => test(or((N ==Int NoneId:Nat), (N ==Int NotImplementedId:Nat)), .Obj, obj(N,ObjState)) ...</k>
       <symbols>... "None" |-> NoneId "NotImplemented" |-> NotImplementedId ...</symbols>
  rule coercion(.Obj) => .Obj

endmodule
