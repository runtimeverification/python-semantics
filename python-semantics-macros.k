module PYTHON-SEMANTICS-MACROS
  imports PYTHON-SEMANTICS-COMMON

  macro assert E:K , Es:K = if #id "__debug__" :
                                               (if not E :
                                                  raise #id "AssertionError" (Es)
                                                else: pass)
                                              else: pass
  macro pass = .K

  macro return = return ref("None")

  macro E [' E2:K , E3:K , Es '] = E [ tuple(E2, E3, Es) ]
  macro E [' E2:K , .SliceItems '] = E [ E2 ]
  macro : : = (ref("slice") (ref("None"), ref("None"), ref("None")))
  macro E : : = (ref("slice") (E, ref("None"), ref("None")))
  macro : E : = (ref("slice") (ref("None"), E, ref("None")))
  macro : : E = (ref("slice") (ref("None"), ref("None"), E))
  macro E : E2 : = (ref("slice") (E, E2, ref("None")))
  macro E : : E2 = (ref("slice") (E, ref("None"), E2))
  macro : E : E2 = (ref("slice") (ref("None"), E, E))
  macro E : E2 : E3 = (ref("slice") (E, E2, E3))

  declare declName : K -> #Id
  define declName(def X:#Id ( _ ) -> _ : _) => X
  define declName(def X ( _ ) : _) => X
  define declName(class X ( _ ) : _) => X
  define declName(K newline _) => declName(K)

  macro @ K:K newline K2:K = (K2 newline (declName(K2), .Expressions) := K(declName(K2), .Expressions))

end module
