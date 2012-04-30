module PYTHON-SEMANTICS-MACROS
  imports PYTHON-SEMANTICS-COMMON

  macro assert E:K , Es:K = if #id "__debug__" :
                                               (if not E :
                                                  raise #id "AssertionError" (Es)
                                                else: pass)
                                              else: pass
  macro pass = .K

  macro return = return ref("None")

  macro : : = (ref("slice") (ref("None"), ref("None"), ref("None"), .Expressions))
  macro E : : = (ref("slice") (E, ref("None"), ref("None"), .Expressions))
  macro : E : = (ref("slice") (ref("None"), E, ref("None"), .Expressions))
  macro : : E = (ref("slice") (ref("None"), ref("None"), E, .Expressions))
  macro E : E2:Expression : = (ref("slice") (E, E2, ref("None"), .Expressions))
  macro E : : E2 = (ref("slice") (E, ref("None"), E2, .Expressions))
  macro : E : E2 = (ref("slice") (ref("None"), E, E, .Expressions))
  macro E : E2 : E3:Expression = (ref("slice") (E, E2, E3, .Expressions))

  declare declName : K -> #Id
  define declName(def X:#Id ( _ ) -> _ : _) => X
  define declName(def X ( _ ) : _) => X
  define declName(class X ( _ ) : _) => X
  define declName(K newline _) => declName(K)

  macro @ K:K newline K2:K = (K2 newline (declName(K2), .Expressions) := K(declName(K2), .Expressions))

end module
