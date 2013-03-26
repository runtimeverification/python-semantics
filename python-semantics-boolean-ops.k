require "python-semantics-ops.k"

module PYTHON-SEMANTICS-BOOLEAN-OPS
  imports PYTHON-SEMANTICS-OPS

  syntax ObjRef ::= bool(K) [strict]
                  | coerceBoolean(Expression, Expression, Expression, Expression, String) [strict(1, 2)]
                  | len(Expression) [strict]
                  | checkBool(Expression) [strict]
                  | checkInt(Expression) [strict]
                  | checkLen(Expression) [strict]
                  | contains(K, Expression) [strict]
                  | index(Expression) [strict]

  rule bool(true) => ref("True")
  rule bool(false) => ref("False")
  rule bool(O:Object) => ref("bool")(O)
  //rule invokeBuiltin(obj("new_bool",_), ListItem(O), .) => newHelper(O, ref("bool"), .) ~> ref("False")
  //rule invokeBuiltin(obj("new_bool",_), ListItem(O:Object) ListItem(O2:Object), .) => newHelper(O, ref("bool"), .) ~> bool(O2)
  rule invokeBuiltin("bool.__new__",_) => newHelper(String2Id("cls"), ref("bool"), .) newline
                                        if plbool(String2Id("x") is ref("None")):
                                          return ref("False")
                                        else:
                                          if hasmember(String2Id("x"), "__bool__") :
                                            String2Id("bool"), .Expressions := getmember(String2Id("x"), "__bool__", true, false, true) (.Arguments) newline
                                            if istype(String2Id("bool"), ref("bool")):
                                              return String2Id("bool")
                                            else:
                                              raiseInternal("TypeError", "__bool__ should return bool")
                                          else:
                                            if hasmember(String2Id("x"), "__len__") :
                                              return ref("len")(String2Id("x")) != 0
                                            else:
                                              return ref("True")
                                           
  rule invokeBuiltin("len",_) => if hasmember(String2Id("s"), "__len__") :
                                 String2Id("len"), .Expressions := getmember(String2Id("s"), "__len__", true, false, true) (.Arguments) newline
                                 String2Id("len"), .Expressions := ref("index")(String2Id("len")) newline
                                 if plbool(String2Id("len") >= 0) :
                                   return String2Id("len")
                                 else:
                                   raiseInternal("ValueError", "__len__() should return >= 0")
                               else:
                                 raiseInternal("TypeError", "object has no len()")

  syntax Test ::= plbool(Expression) [strict]
  rule plbool(obj(_, <oattrs>... "__value__" |-> I:Int ...</oattrs>)) => I =/=Int 0 [function, anywhere]

  rule not O:Object => bool(negate(plbool(bool(O))))
  rule O:Object and K:K => test(plbool(bool(O)), K, O)
  rule O:Object or K => test(plbool(bool(O)), O, K)

  syntax ObjRef ::= "comparison" "(" Expression "," Expression "," KLabel ")" [strict(1), klabel('comparison)]

  rule A:Expression is B:Expression => comparison(A, B, '_is_) [macro, anywhere]
  rule A:Expression is not B:Expression => comparison(A, B, '_isnot_) [macro, anywhere]
  rule A:Expression < B:Expression => comparison(A, B, '_<_) [macro, anywhere]
  rule A:Expression > B:Expression => comparison(A, B, '_>_) [macro, anywhere]
  rule A:Expression <= B:Expression => comparison(A, B, '_<=_) [macro, anywhere]
  rule A:Expression >= B:Expression => comparison(A, B, '_>=_) [macro, anywhere]
  rule A:Expression != B:Expression => comparison(A, B, '_!=_) [macro, anywhere]
  rule A:Expression == B:Expression => comparison(A, B, '_==_) [macro, anywhere]
  rule A:Expression in B:Expression => comparison(A, B, '_in_) [macro, anywhere]
  rule A:Expression not in B:Expression => comparison(A, B, '_notin_) [macro, anywhere]

  context comparison(O:Object, HOLE, _) when getKLabel HOLE =/=KLabel 'comparison
  context comparison(O:Object, comparison(HOLE, _, _), _)
  rule comparison(O:Object, comparison(O2:Object, Rest, Lbl2), Lbl) => comparison(O, O2, Lbl) and comparison(O2, Rest, Lbl2)

  rule comparison(obj(B:ObjId,_), obj(B2:ObjId,_), '_is_) => bool(B ==K B2)
  rule comparison(O:Object, O2:Object, '_isnot_) => not (O is O2)
  rule comparison(O:Object, O2:Object, '_<_) => coerceBoolean(O, O2, "__lt__", "__gt__", "<")
  rule comparison(O:Object, O2:Object, '_>_) => coerceBoolean(O, O2, "__gt__", "__lt__", ">")
  rule comparison(O:Object, O2:Object, '_<=_) => coerceBoolean(O, O2, "__le__", "__ge__", "<=")
  rule comparison(O:Object, O2:Object, '_>=_) => coerceBoolean(O, O2, "__ge__", "__le__", ">=")
  rule comparison(O:Object, O2:Object, '_!=_) => coerceBinaryBase(O, O2, "__ne__", "__ne__") -> (not (O == O2))
  rule comparison(O:Object, O2:Object, '_==_) => coerceBinaryBase(O, O2, "__eq__", "__eq__") -> (O is O2)
  rule comparison(O:Object, O2:Object, '_in_) => bool((getmember(O2, "__contains__", true, false, false) (O)) -> contains(iterate(O2, .), O))
  rule comparison(O:Object, O2:Object, '_notin_) => not O in O2

  rule contains(list(ListItem(O:Object) L:List), O2) => ref("True") if O == O2 else contains(list(L), O2)
  context contains(list(ListItem(HOLE) _), _)
  rule contains(list(.), O2) => ref("False")

  rule <k> coerceBoolean(O, O2, X, RX, S:String) => coerceBinaryBase(O, O2, X, RX) -> (raiseInternal("TypeError", "unorderable types: " +String S)) ...</k>

endmodule

