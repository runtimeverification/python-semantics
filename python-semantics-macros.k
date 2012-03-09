module PYTHON-SEMANTICS-MACROS
  imports PYTHON-SEMANTICS-COMMON

  macro assert E:K , Es:K = if #id "__debug__" :
                                               (if not E :
                                                  raise ref("AssertionError") (Es)
                                                else: pass)
                                              else: pass
  macro pass = .K

  macro (O:Object , O2:Object) , O3:Object = O:Object , (O2:Object , O3:Object)

  macro return = return ref("None")

end module
