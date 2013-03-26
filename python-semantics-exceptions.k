require "python-semantics-common.k"

module PYTHON-SEMANTICS-EXCEPTIONS
  imports PYTHON-SEMANTICS-COMMON

  rule invokeBuiltin("BaseException.__new__","cls" |-> Cls:Object "args" |-> Args:Object "kwargs" |-> KwArgs:Object) =>
    newHelper(Cls, ref("BaseException"), .) ~> 
    return mutable("args" |-> Args, Cls)
                                                   
  //rule invokeBuiltin(obj("ImportError.__init__",_), ListItem(O) _, M:Map) => keywordHelper("ImportError", M, SetItem("name") SetItem("path")) ~> #if "name" in keys(M) #then setref(id(O), "name", M("name")) #else . #fi ~> #if "path" in keys(M) #then setref(id(O), "path", M("path")) #else . #fi ~> ref("None")

endmodule
