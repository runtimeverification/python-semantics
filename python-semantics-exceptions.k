require "python-semantics-common.k"

module PYTHON-SEMANTICS-EXCEPTIONS
  imports PYTHON-SEMANTICS-COMMON

  rule <k> invokeBuiltin(obj("BaseException.__new__",_), ListItem(O) L:List, M:Map) => newHelper(O, ref("BaseException"), .) ~> setref(N, "__dict__", {.KeyData}) ~> setref(N, "args", immutable(list(Refify(Idify(L))), ref("tuple"))) ~> ref(N) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>
         <id>N</id>
         <oattrs> "__class__" |-> ref(id(O)) </oattrs>
       </object>) [allocatoin]

  rule invokeBuiltin(obj("ImportError.__init__",_), ListItem(O) _, M:Map) => keywordHelper("ImportError", M, SetItem("name") SetItem("path")) ~> #if "name" in keys(M) #then setref(id(O), "name", M("name")) #else . #fi ~> #if "path" in keys(M) #then setref(id(O), "path", M("path")) #else . #fi ~> ref("None")

endmodule
