require "python-semantics-common.k"

module PYTHON-SEMANTICS-BUILTIN-FUNCTIONS
  imports PYTHON-SEMANTICS-COMMON

  rule invokeBuiltin("all",_) => (for String2Id("element") in String2Id("iterable") :
                                   if String2Id("element") :
                                     return ref("True")
                                 else: pass) ~>
                                 return ref("False")

endmodule
