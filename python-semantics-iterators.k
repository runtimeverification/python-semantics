require "python-semantics-literals.k"
require "python-semantics-try.k"

module PYTHON-SEMANTICS-ITERATORS
  imports PYTHON-SEMANTICS-LITERALS
  imports PYTHON-SEMANTICS-TRY

  rule <k> invokeBuiltin(obj("get_iter",_), ListItem(obj(_:ObjId,<oattrs>... "__value__" |-> K:K ...</oattrs>)), .) => mutable(K, ref("iterator")) ...</k>

  rule <k> invokeBuiltin(obj("iter_iter",_), ListItem(O:Object), .) => O ...</k>
  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B:ObjId,_)), .) => B2 ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> list((ListItem(B2) => .) L:List) ...</oattrs>
       ...</object>
  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => raise ref("StopIteration") ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> list(.) ...</oattrs>
       ...</object>

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => try: (getmember(B2, "__getitem__", true, false, true) (I:Int)) except ref("IndexError"): (setx(.Obj) ~> raise ref("StopIteration")) else: .K  ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__index__" |-> (I => I +Int 1) "__value__" |-> B2 ...</oattrs>
       ...</object>


  syntax ObjRef ::= "checkIter" "(" Exp ")" [strict]

  rule <k> invokeBuiltin(obj("iter",_), ListItem(O), .) => checkIter(getmember(O, "__iter__", true, false, false) (.Arguments) -> test(getmember(O, "__getitem__", true, false, false) =/=Obj .Obj, mutable("__index__" |-> 0 "__value__" |-> ref(id(O)), ref("iterator")), .Obj) -> (raiseInternal("TypeError", "object is not iterable"))) ...</k>

  rule <k> checkIter(O) => test(getmember(O, "__next__", true, false, false) ==Obj .Obj, raiseInternal("TypeError", "iter() returned non-iterator"), O) ...</k>
  //TODO: sentinels

endmodule
