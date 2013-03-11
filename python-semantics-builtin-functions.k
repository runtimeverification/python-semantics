require "python-semantics-common.k"

module PYTHON-SEMANTICS-BUILTIN-FUNCTIONS
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= doAll(Exp) [strict]

  rule invokeBuiltin(obj("all",_), ListItem(O:Object), .) => try: doAll(ref("iter")(O)) except ref("StopIteration"): ref("True") else: pass
  rule doAll(Iter:Object) => if not getmember(Iter, "__next__", true, false, true)(.Arguments) : ref("False") else: doAll(Iter)

endmodule
