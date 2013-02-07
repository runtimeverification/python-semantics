require "python-semantics-common.k"

module PYTHON-SEMANTICS-BUILTIN-FUNCTIONS
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= doAll(Expression)

  rule invokeBuiltin(obj("all",_), ListItem(O), .) => iterate(O, .) ~> doAll(ref("True"))
  rule list((ListItem(O) => .) L:List) ~> doAll((O2 => O2 and O))
  rule list(.List) ~> doAll(O) => ref("bool")(O)

endmodule
