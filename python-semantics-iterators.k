require "python-semantics-literals.k"
require "python-semantics-try.k"

module PYTHON-SEMANTICS-ITERATORS
  imports PYTHON-SEMANTICS-LITERALS
  imports PYTHON-SEMANTICS-TRY

  rule <k> invokeBuiltin(obj("get_iter",_), ListItem(obj(_:Builtin,<oattrs>... "__value__" |-> K:K ...</oattrs>)), .) => mutable(K, ref("iterator")) ...</k>

  rule <k> invokeBuiltin(obj("iter_iter",_), ListItem(O:Object), .) => O ...</k>
  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B:Builtin,_)), .) => ref(B2:Builtin) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> list((ListItem(B2) => .) L:List) ...</oattrs>
       ...</object>
  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => raise ref("StopIteration") ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> list(.) ...</oattrs>
       ...</object>

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B,_)), .) => try: (getmember(ref(B2), "__getitem__", true, false, true) (I:Int)) except ref("IndexError"): (setx(.Obj) ~> raise ref("StopIteration")) else: pass  ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__index__" |-> (I => I +Int 1) "__value__" |-> B2 ...</oattrs>
       ...</object>


  syntax ObjRef ::= "checkIter" "(" Expression ")" [strict]

  rule <k> invokeBuiltin(obj("call_iter",_), ListItem(O), .) => checkIter(getmember(O, "__iter__", true, false, false) (.Arguments) -> test(getmember(O, "__getitem__", true, false, false) =/=Obj .Obj, mutable("__index__" |-> 0 "__value__" |-> id(O), ref("iterator")), .Obj) -> (raiseInternal("TypeError", "object is not iterable"))) ...</k>

  rule <k> checkIter(O) => test(getmember(O, "__next__", true, false, false) ==Obj .Obj, raiseInternal("TypeError", "iter() returned non-iterator"), O) ...</k>
  //TODO: sentinels

endmodule
