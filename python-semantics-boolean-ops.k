module PYTHON-SEMANTICS-BOOLEAN-OPS
  imports PYTHON-SEMANTICS-OPS

  syntax ObjRef ::= "bool" "(" Test ")" [:strict:]
                  | "bool" "(" Expression ")" [:strict:]
                  | "coerceBoolean" "(" Expression "," Expression "," #Id "," #Id "," #String ")" [:strict(1 2):]
                  | "len" "(" Expression ")" [:strict:]
                  | "checkBool" "(" Expression ")" [:strict:]
                  | "checkInt" "(" Expression ")" [:strict:]
                  | "checkLen" "(" Expression ")" [:strict:]

  rule bool(true) => ref("True")
  rule bool(false) => ref("False")
  rule bool(O:Object) => test(plbool(O is ref("None")), ref("False"), checkBool(getmember(O, #id "__bool__", true, false, false) ()) -> checkInt(len(O)) -> ref("True")) 
  rule checkBool(O) => test(istype(O, ref("bool")), O, raiseInternal("TypeError", "__bool__ should return bool"))
  rule checkBool(.Obj) => .Obj
  rule checkInt(O) => test(intvalue(O) ==Bool 0, ref("False"), ref("True"))
  rule checkInt(.Obj) => .Obj
  rule invokeBuiltin(obj("new_bool",_), ListItem(O), .) => newHelper(O, ref("bool"), .) ~> ref("False")
  rule invokeBuiltin(obj("new_bool",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("bool"), .) ~> bool(O2)

  rule len(O) => checkLen(getmember(O, #id "__len__", true, false, false) ())
  rule checkLen(O) => test(istype(O, ref("int")), test(intvalue(O) >=Int 0, O, raiseInternal("ValueError", "__len__() should return >= 0")), raiseInternal("TypeError", "object cannot be interpreted as an integer"))
  rule checkLen(.Obj) => .Obj
  rule invokeBuiltin(obj("call_len",_), ListItem(O), .) => len(O) -> raiseInternal("TypeError", "object has no len()")

  declare plbool : Expression -> Test
  define plbool(obj(_, <oattrs>... "__value__" |-> I:#Int ...</oattrs>)) => I =/=Bool 0
  context plbool(HOLE)  

  rule <k> not O => bool(negate(plbool(bool(O)))) ...</k>
  rule <k> O and K:K => test(plbool(bool(O)), K, O) ...</k>
  rule <k> O or K => test(plbool(bool(O)), O, K) ...</k>

  rule <k> obj(B:Builtin,_) is obj(B2:Builtin,_) => bool(B ==Bool B2) ...</k>
  rule <k> O is not O2 => not (O is O2) ...</k>
  rule <k> O < O2:Object => coerceBoolean(O, O2, #id "__lt__", #id "__gt__", "<") ...</k>
  rule <k> O > O2 => coerceBoolean(O, O2, #id "__gt__", #id "__lt__", ">") ...</k>
  rule <k> O <= O2 => coerceBoolean(O, O2, #id "__le__", #id "__ge__", "<=") ...</k>
  rule <k> O >= O2 => coerceBoolean(O, O2, #id "__ge__", #id "__le__", ">=") ...</k>
  rule <k> O != O2 => coerceBinaryBase(O, O2, #id "__ne__", #id "__ne__") -> (O is not O2) ...</k>
  rule <k> O == O2 => coerceBinaryBase(O, O2, #id "__eq__", #id "__eq__") -> (O is O2) ...</k>

  rule <k> Lbl(O,,(Lbl2(O2,,Cmp))) => '_and_(Lbl(O,,O2),,Lbl2(O2,,Cmp)) ...</k>
  when _and-then_(Lbl ==Bool '_<_ or-else Lbl ==Bool '_>_ or-else Lbl ==Bool '_==_ or-else Lbl ==Bool '_>=_ or-else Lbl ==Bool '_<=_ or-else Lbl ==Bool '_!=_
  or-else Lbl ==Bool '_is_ or-else Lbl ==Bool '_is`not_ or-else Lbl ==Bool '_in_ or-else Lbl ==Bool '_not`in_,
  Lbl2 ==Bool '_<_ or-else Lbl2 ==Bool '_>_ or-else Lbl2 ==Bool '_==_ or-else Lbl2 ==Bool '_>=_ or-else Lbl2 ==Bool '_<=_ or-else Lbl2 ==Bool '_!=_
  or-else Lbl2 ==Bool '_is_ or-else Lbl2 ==Bool '_is`not_ or-else Lbl2 ==Bool '_in_ or-else Lbl2 ==Bool '_not`in_)

  context Lbl:KLabel(O,,Lbl2:KLabel(HOLE,,Cmp:K))
  when _and-then_(Lbl ==Bool '_<_ or-else Lbl ==Bool '_>_ or-else Lbl ==Bool '_==_ or-else Lbl ==Bool '_>=_ or-else Lbl ==Bool '_<=_ or-else Lbl ==Bool '_!=_
  or-else Lbl ==Bool '_is_ or-else Lbl ==Bool '_is`not_ or-else Lbl ==Bool '_in_ or-else Lbl ==Bool '_not`in_,
  Lbl2 ==Bool '_<_ or-else Lbl2 ==Bool '_>_ or-else Lbl2 ==Bool '_==_ or-else Lbl2 ==Bool '_>=_ or-else Lbl2 ==Bool '_<=_ or-else Lbl2 ==Bool '_!=_
  or-else Lbl2 ==Bool '_is_ or-else Lbl2 ==Bool '_is`not_ or-else Lbl2 ==Bool '_in_ or-else Lbl2 ==Bool '_not`in_)

  context Lbl:KLabel(O,,HOLE)
  when _and-then_(Lbl ==Bool '_<_ or-else Lbl ==Bool '_>_ or-else Lbl ==Bool '_==_ or-else Lbl ==Bool '_>=_ or-else Lbl ==Bool '_<=_ or-else Lbl ==Bool '_!=_
  or-else Lbl ==Bool '_is_ or-else Lbl ==Bool '_is`not_ or-else Lbl ==Bool '_in_ or-else Lbl ==Bool '_not`in_,
  notBool(getKLabel HOLE ==Bool '_<_ or-else getKLabel HOLE ==Bool '_>_ or-else getKLabel HOLE ==Bool '_==_ or-else getKLabel HOLE ==Bool '_>=_ 
  or-else getKLabel HOLE ==Bool '_<=_ or-else getKLabel HOLE ==Bool '_!=_ or-else getKLabel HOLE ==Bool '_is_ or-else getKLabel HOLE ==Bool '_is`not_
  or-else getKLabel HOLE ==Bool '_in_ or-else getKLabel HOLE ==Bool '_not`in_))

  rule <k> coerceBoolean(O, O2, X:#Id, RX:#Id, S:#String) => coerceBinaryBase(O, O2, X, RX) -> (raiseInternal("TypeError", "unorderable types: " +String S)) ...</k>

end module

