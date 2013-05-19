require "python-semantics-common.k"

module PYTHON-SEMANTICS-BUILTIN-FUNCTIONS
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= doAll(Exp) [strict]

  rule invokeBuiltin(obj("all",_), ListItem(O:Object), .) => try: doAll(ref("iter")(O)) except ref("StopIteration"): ref("True") else: pass
  rule doAll(Iter:Object) => if not getmember(Iter, "__next__", true, false, true)(.Arguments) : ref("False") else: doAll(Iter)

  rule invokeBuiltin(obj("super.__new__",_), ListItem(Cls) L:List, .) => newHelper(Cls, ref("super"), .) ~> mutable("__self__" |-> ref("None") "__self_class__" |-> ref("None") "__thisclass__" |-> ref("None"), ref("super"))
  rule <k> invokeBuiltin(obj("super.__init__",_), ListItem(O), .) => #if ArgCount >Int 0 #then if VarNames[0] in Locals: if "__class__" in Cells: test(getattr2(Cells["__class__"], "cell_contents") =/=Obj .Obj, test(istype(getref2(Cells["__class__"], "cell_contents"), ref("type")), ref("super.__init__")(O, getref2(Cells["__class__"], "cell_contents"), Locals[VarNames[0]]), raiseInternal("SystemError", "super(): __class__ is not a type")), raiseInternal("SystemError", "super(): empty __class__ cell")) else: raiseInternal("SystemError", "super(): __class__ cell not found") else: raiseInternal("SystemError", "super(): arg[0] deleted") #else raiseInternal("SystemError", "super(): no arguments") #fi ...</k>
       <frameObject> N </frameObject>
       <object>...
         <id> N </id>
         <oattrs>... "f_code" |-> ref(N2) "f_cells" |-> Cells "f_locals" |-> Locals ...</oattrs>
       ...</object>
       <object>...
         <id> N2 </id>
         <oattrs>... "co_argcount" |-> ArgCount "co_varnames" |-> VarNames ...</oattrs>
       ...</object>
  rule invokeBuiltin(obj("super.__init__",_), ListItem(O) ListItem(ThisClass), .) => ref("super.__init__")(O, ThisClass, ref("None"))
  rule invokeBuiltin(obj("super.__init__",_), ListItem(O) ListItem(ThisClass) ListItem(Self), .) => test(istype(ThisClass, ref("type")), setref(id(O), "__thisclass__", ThisClass), raiseInternal("TypeError", "must be type")) ~> test(istype(Self, ThisClass) or hasbase(Self, ThisClass) or Self is None, setref(id(O), "__self__", Self), raiseInternal("TypeError", "super(type, obj): obj must be instance or subtype of type")) ~> test(istype(Self, ThisClass), setref(id(O), "__self_class__", getref(Self, "__class__")), test(hasbase(Self, ThisClass), setref(id(O), "__self_class__", Self), setref(id(O), "__self_class__", ref("None")))) ~> ref("None")

endmodule
