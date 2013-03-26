require "python-semantics-literals.k"
require "python-semantics-try.k"

module PYTHON-SEMANTICS-ITERATORS
  imports PYTHON-SEMANTICS-LITERALS
  imports PYTHON-SEMANTICS-TRY

  rule invokeBuiltin("tuple.__iter__",_) => return valueIterator(String2Id("self"))
  rule invokeBuiltin("list.__iter__",_) => return valueIterator(String2Id("self"))

  rule invokeBuiltin("iterator.__iter__",_) => return String2Id("self")
  rule <k> invokeBuiltin("iterator.__next__", "self" |-> obj(Self,_)) => return B ...</k>
       <object>...
         <id>Self</id>
         <oattrs>... "__value__" |-> list((ListItem(B) => .) L:List) ...</oattrs>
       ...</object>
  rule <k> invokeBuiltin("iterator.__next__", "self" |-> obj(Self,_)) => raise ref("StopIteration") ...</k>
       <object>...
         <id>Self</id>
         <oattrs>... "__value__" |-> list(.) ...</oattrs>
       ...</object>

  //rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => try: (getmember(B2, "__getitem__", true, false, true) (I:Int)) except ref("IndexError"): (setx(.Obj) ~> raise ref("StopIteration")) else: pass  ...</k>
  //     <object>...
  //       <id>B</id>
  //       <oattrs>... "__index__" |-> (I => I +Int 1) "__value__" |-> B2 ...</oattrs>
  //     ...</object>



  rule invokeBuiltin("iter",_) => (if hasmember(String2Id("object"), "__iter__") :
                                  String2Id("object"), .Expressions := getmember(String2Id("object"), "__iter__", true, false, true) (.Arguments)
                                else:
                                  if hasmember(String2Id("object"), "__getitem__") :
                                    String2Id("object"), .Expressions := getitemIterator(String2Id("object"))
                                  else:
                                    raiseInternal("TypeError", "object is not iterable")) newline
                                if hasmember(String2Id("object"), "__next__"):
                                  return String2Id("object")
                                else:
                                  raiseInternal("TypeError", "iter() returned non-iterator")
  //TODO: sentinels

  syntax Expression ::= getitemIterator(Expression) [strict]
  rule getitemIterator(O:Object) => mutable("__index__" |-> 0 "__value__" |-> ref(id(O)), ref("iterator"))
  syntax Expression ::= valueIterator(Expression) [strict]
  rule valueIterator(O:Object) => mutable(getattr(O, "__value__"), ref("iterator"))

endmodule
