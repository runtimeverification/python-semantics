module PYTHON-SEMANTICS-BOOLEAN-OPS
  imports PYTHON-SEMANTICS-OPS

  syntax ObjRef ::= "bool" "(" Test ")" [strict]
                  | "bool" "(" Expression ")" [strict]
                  | "coerceBoolean" "(" Expression "," Expression "," Id "," Id "," String ")" [strict(1 2)]
                  | "len" "(" Expression ")" [strict]
                  | "checkBool" "(" Expression ")" [strict]
                  | "checkInt" "(" Expression ")" [strict]
                  | "checkLen" "(" Expression ")" [strict]
                  | "contains" "(" ListRef "," Expression ")" [strict]

  rule bool(true) => ref("True")
  rule bool(false) => ref("False")
  rule bool(O:Object) => test(plbool(O is ref("None")), ref("False"), checkBool(getmember(O, String2Id("__bool__"), true, false, false) ()) -> checkInt(len(O)) -> ref("True")) 
  rule checkBool(O) => test(istype(O, ref("bool")), O, raiseInternal("TypeError", "__bool__ should return bool"))
  rule checkBool(.Obj) => .Obj
  rule checkInt(O) => test(intvalue(O) ==Int 0, ref("False"), ref("True"))
  rule checkInt(.Obj) => .Obj
  rule invokeBuiltin(obj("new_bool",_), ListItem(O), .) => newHelper(O, ref("bool"), .) ~> ref("False")
  rule invokeBuiltin(obj("new_bool",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("bool"), .) ~> bool(O2)

  rule len(O) => checkLen(getmember(O, String2Id("__len__"), true, false, false) ())
  rule checkLen(O) => test(istype(O, ref("int")), test(intvalue(O) >=Int 0, O, raiseInternal("ValueError", "__len__() should return >= 0")), raiseInternal("TypeError", "object cannot be interpreted as an integer"))
  rule checkLen(.Obj) => .Obj
  rule invokeBuiltin(obj("call_len",_), ListItem(O), .) => len(O) -> raiseInternal("TypeError", "object has no len()")

  syntax Test ::= "plbool" "(" Expression ")" [function]
  rule plbool(obj(_, <oattrs>... "__value__" |-> I:Int ...</oattrs>)) => I =/=Int 0 [function, anywhere]
  context plbool(HOLE)  

  rule not O => bool(negate(plbool(bool(O))))
  rule O and K:K => test(plbool(bool(O)), K, O)
  rule O or K => test(plbool(bool(O)), O, K)

  rule obj(B:Builtin,_) is obj(B2:Builtin,_) => bool(B ==K B2)
  rule O is not O2 => not (O is O2)
  rule O < O2:Object => coerceBoolean(O, O2, String2Id("__lt__"), String2Id("__gt__"), "<")
  rule O > O2 => coerceBoolean(O, O2, String2Id("__gt__"), String2Id("__lt__"), ">")
  rule O <= O2 => coerceBoolean(O, O2, String2Id("__le__"), String2Id("__ge__"), "<=")
  rule O >= O2 => coerceBoolean(O, O2, String2Id("__ge__"), String2Id("__le__"), ">=")
  rule O != O2 => coerceBinaryBase(O, O2, String2Id("__ne__"), String2Id("__ne__")) -> (O is not O2)
  rule O == O2 => coerceBinaryBase(O, O2, String2Id("__eq__"), String2Id("__eq__")) -> (O is O2)
  rule O in O2 => bool((getmember(O2, String2Id("__contains__"), true, false, false) (O)) -> contains(iterate(O2, .), O))
  rule O not in O2 => not (O in O2)

  rule contains(list(ListItem(O) L:List), O2) => ref("True") if O == O2 else contains(list(L), O2)
  rule contains(list(ListItem(B) L:List), O2) => ref("True") if ref(B) == O2 else contains(list(L), O2)
  rule contains(list(.), O2) => ref("False")

  syntax Bool ::= "isComparison" "(" KLabel ")" [function]
  rule isComparison(Lbl) => Lbl ==KLabel '_<_ orElseBool Lbl ==KLabel '_>_ orElseBool Lbl ==KLabel '_==_ orElseBool Lbl ==KLabel '_>=_ orElseBool Lbl ==KLabel '_<=_ [function, anywhere]
  orElseBool Lbl ==KLabel '_!=_ orElseBool Lbl ==KLabel '_is_ orElseBool Lbl ==KLabel '_is`not_ orElseBool Lbl ==KLabel '_in_ orElseBool Lbl ==KLabel '_not`in_

  rule <k> Lbl(O,,(Lbl2(O2,,Cmp))) => '_and_(Lbl(O,,O2),,Lbl2(O2,,Cmp)) ...</k>
  when isComparison(Lbl) andThenBool isComparison(Lbl2)

  context Lbl:KLabel(O,,Lbl2:KLabel(HOLE,,Cmp:K))
  when isComparison(Lbl) andThenBool isComparison(Lbl2)

  context Lbl:KLabel(O,,HOLE)
  when isComparison(Lbl) andThenBool notBool(isComparison(getKLabel HOLE))

  rule <k> coerceBoolean(O, O2, X:Id, RX:Id, S:String) => coerceBinaryBase(O, O2, X, RX) -> (raiseInternal("TypeError", "unorderable types: " +String S)) ...</k>

endmodule

