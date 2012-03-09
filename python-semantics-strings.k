module PYTHON-SEMANTICS-STRINGS
  imports PYTHON-SEMANTICS-BOOLEAN-OPS
  imports MACHINE-INTEGERS

  rule <k> invokeBuiltin(obj("add_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", strvalue(O) +String strvalue(O2)) ...</k>
  rule <k> invokeBuiltin(obj("radd_str",_), ListItem(O:Object) ListItem(O2:Object), .) => invokeBuiltin(ref("add_str"), ListItem(O2) ListItem(O), .) ...</k>

  rule <k> invokeBuiltin(obj("eq_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", bool(strvalue(O) ==Bool strvalue(O2))) ...</k>
  rule <k> invokeBuiltin(obj("ne_str",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "str", "str", bool(strvalue(O) =/=Bool strvalue(O2))) ...</k>

  rule <k> invokeBuiltin(obj("hash_str",_), ListItem(O), .) => test(lengthString(strvalue(O)) ==Bool 0, 0, accumulate(strvalue(O), asciiString(char(substrString(strvalue(O), 0, 1))) <<Int 7, lengthString(strvalue(O)))) ...</k>

  syntax ObjRef ::= "accumulate" "(" #String "," #Int "," #Int ")"

  declare char : #String -> #Char
  define char(C:#Char) => C

  rule <k> accumulate((S:#String => substrString(S, 1, lengthString(S) -Int 1)), (I:#Int => (mult(Imag, I, Width) xorInt asciiString(char(substrString(S, 0, 1))))), _) ...</k>
       <symbols>... "sys" |-> Sys:Builtin ...</symbols>
       <object>...
         <id>Sys</id>
         <oattrs>... "hash_info" |-> list(ListItem(Width:#Nat) ListItem(_) ListItem(_) ListItem(_) ListItem(Imag:#Int)) ...</oattrs>
       ...</object> when lengthString(S) =/=Bool 0

  rule <k> accumulate("", I, Len:#Nat) => test((I xorInt Len) ==Bool -1, -2, (I xorInt Len)) ...</k>

end module
