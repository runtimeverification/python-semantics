#!/usr/bin/env python3.2

import ast
import re
import sys

class KPythonVisitor(ast.NodeVisitor):

  def visit_Module(self, node):
    return self.visit_list(node.body, "'_newline_")

  def visit_list(self, nodes, op, dotlist=None):
    if dotlist and len(nodes) == 1:
      return op + "(" + self.visit(nodes[0]) + ",," + "'.List`{\"" + dotlist + "\"`}(.List{K}))"
    elif len(nodes) == 1:
      return self.visit(nodes[0])
    elif dotlist and len(nodes) == 0:
      return "'.List`{\"" + dotlist + "\"`}(.List{K})"
    return op + "(" + self.visit(nodes[0]) + ",," + self.visit_list(nodes[1:], op, dotlist) + ")"

  def visit_FunctionDef(self, node):
    if not node.returns:
      return self.decorate("'def_`(_`):_(" + self.getid(node.name) + ",," + self.getparams(node.args) + ",," + self.visit_list(node.body, "'_newline_") + ")", node.decorator_list)
    else:
      return self.decorate("'def_`(_`)->_:_(" + self.getid(node.name) + ",," + self.getparams(node.args) + ",," + self.visit(node.returns) + ",," + self.visit_list(node.body, "'_newline_") + ")", node.decorator_list)

  def decorate(self, function, decorators):
    if not decorators:
      return function
    else:
      return "'@_newline_(" + self.visit(decorators[0]) + ",," + self.decorate(function, decorators[1:]) + ")" 

  def getparams(self, args):
    result = []
    default_index = len(args.args) - len(args.defaults)
    for i in range(0, len(args.args)):
      arg = args.args[i]
      if arg.annotation:
        if i >= default_index:
          result.append("'_:_('_=_(" + self.getid(arg.arg) + ",," + self.visit(args.defaults[i - default_index]) + "),," + self.visit(arg.annotation) + ")")
        else:
          result.append("'_:_(" + self.getid(arg.arg) + ",," + self.visit(arg.annotation) + ")")
      else:
        if i >= default_index:
          result.append("'_=_(" + self.getid(arg.arg) + ",," + self.visit(args.defaults[i - default_index]) + ")")
        else:
          result.append(self.getid(arg.arg))
    if args.vararg:
      if args.varargannotation:
        result.append("'_:_('*_(" + self.getid(args.vararg) + "),," + self.visit(args.varargannotation) + ")")
      else:
        result.append("'*_(" + self.getid(args.vararg) + ")")
    else:
      result.append("'*(.List{K})")
    for i in range(0, len(args.kwonlyargs)):
      arg = args.kwonlyargs[i]
      if arg.annotation:
        if args.kw_defaults[i]:
          result.append("'_:_('_=_(" + self.getid(arg.arg) + ",," + self.visit(args.kw_defaults[i]) + "),," + self.visit(arg.annotation) + ")")
        else:
          result.append("'_:_(" + self.getid(arg.arg) + ",," + self.visit(arg.annotation) + ")")
      else:
        if args.kw_defaults[i]:
          result.append("'_=_(" + self.getid(arg.arg) + ",," + self.visit(args.kw_defaults[i]) + ")")
        else:
          result.append(self.getid(arg.arg))
    if args.kwarg:
      if args.kwargannotation:
        result.append("'_:_('**_(" + self.getid(args.kwarg) + "),," + self.visit(args.kwargannotation) + ")")
      else:
        result.append("'**_(" + self.getid(args.kwarg) + ")")
    return self.dolist(result)

  def dolist(self, result):
    if not result:
      return "'.List`{\",\"`}(.List{K})"
    else:
      return "'_`,_(" + result[0] + ",," + self.dolist(result[1:]) + ")"

  def visit_Return(self, node):
    if node.value:
      return "'return_(" + self.visit(node.value) + ")"
    else:
      return "'return(.List{K})"

  def visit_Assign(self, node):
    return "'_:=_(" + self.visit_list(node.targets, "'_`,_",",") + ",," + self.visit(node.value) + ")"

  def visit_For(self, node):
    return "'for_in_:_else`:_(" + self.visit(node.target) + ",," + self.visit(node.iter) + ",," + self.visit_list(node.body,"'_newline_") + ",," + (self.visit_list(node.orelse,"'_newline_") if node.orelse else "'pass(.List{K})") + ")"

  def visit_While(self, node):
    return "'while_:_else`:_(" + self.visit(node.test) + ",," + self.visit_list(node.body,"'_newline_") + ",," + (self.visit_list(node.orelse,"'_newline_") if node.orelse else "'pass(.List{K})") + ")"

  def visit_If(self, node):
    return ("'if_:_else`:_(" + self.visit(node.test) + ",,"
            + self.visit_list(node.body,"'_newline_") + ",," + (self.visit_list(node.orelse,"'_newline_") if node.orelse else "'pass(.List{K})") + ")")

  def visit_Raise(self, node):
    if not node.exc:
      return "'raise(.List{K})"
    elif not node.cause:
      return "'raise_(" + self.visit(node.exc) + ")"
    else:
      return "'raise_from_(" + self.visit(node.exc) + ",," + self.visit(node.cause) + ")"

  def visit_TryExcept(self, node):
    return "'try`:__else`:_(" + self.visit_list(node.body, "'_newline_") + ",," + self.visit_list(node.handlers, "'_except_","except") + ",," + (self.visit_list(node.orelse, "'_newline_") if len(node.orelse) > 0 else "'pass(.List{K})") + ")"

  def visit_ExceptHandler(self, node):
    if not node.type:
      return "'except`:_(" + self.visit_list(node.body, "'_newline_") + ")"
    elif not node.name:
      return "'except_:_(" + self.visit(node.type) + ",," + self.visit_list(node.body, "'_newline_") + ")"
    else:
      return "'except_as_:_(" + self.visit(node.type) + ",," + self.getid(node.name) + ",," + self.visit_list(node.body, "'_newline_") + ")"

  def visit_TryFinally(self, node):
    return "'try`:_finally`:_(" + self.visit_list(node.body, "'_newline_") + ",," + self.visit_list(node.finalbody, "'_newline_") + ")"

  def visit_Assert(self, node):
    return ("'assert_('_`,_(" + self.visit(node.test)
            + (",,'_`,_(" + self.visit(node.msg) if node.msg else "") + ",,'.List`{\",\"`}(.List{K})))" + (")" if node.msg else ""))

  def visit_Expr(self, node):
    return "'_;(" + self.visit(node.value) + ")"

  def visit_Pass(self, node):
    return "'pass(.List{K})"

  def visit_Break(self, node):
    return "'break(.List{K})"

  def visit_Continue(self, node):
    return "'continue(.List{K})"

  def visit_BoolOp(self, node):
    return self.visit_list(node.values, self.visit(node.op))

  def visit_BinOp(self, node):
    return self.visit(node.op) + "(" + self.visit(node.left) + ",," + self.visit(node.right) + ")"

  def visit_UnaryOp(self, node):
    return self.visit(node.op) + "(" + self.visit(node.operand) + ")"

  def visit_ops(self, nodes, ops):
    if len(nodes) == 1:
      return self.visit(nodes[0])
    return ops[0] + "(" + self.visit(nodes[0]) + ",," + self.visit_ops(nodes[1:], ops[1:]) + ")"

  def visit_Dict(self, node):
    result = "'`{_`}("
    for i in range(len(node.keys)):
      result += "'_`,_('_:_(" + self.visit(node.keys[i]) + ",," + self.visit(node.values[i]) + "),,"
    result += "'.List`{\",\"`}(.List{K})"
    result += ")" * (len(node.keys) + 1)
    return result
 
  def visit_Compare(self, node):
    return self.visit(node.ops[0]) + "(" + self.visit(node.left) + ",," + self.visit_ops(node.comparators, [self.visit(n) for n in node.ops[1:]]) + ")"

  def visit_Call(self, node):
    return "'_`(_`)(" + self.visit(node.func) + ",," + self.getargs(node.args, node.keywords, node.starargs, node.kwargs) + ")"

  def getargs(self, args, keywords, starargs, kwargs):
    nodes = []
    for arg in args:
      nodes.append(self.visit(arg))
    for keyword in keywords:
      nodes.append("'_=_(" + self.getid(keyword.arg) + ",," + self.visit(keyword.value) + ")")
    if starargs:
      nodes.append("'*_(" + self.visit(starargs) + ")")
    if kwargs:
      nodes.append("'**_(" + self.visit(kwargs) + ")")
    result = ""
    for node in nodes:
      result += "'_`,_(" + node + ",,"
    result += "'.List`{\",\"`}(.List{K})" 
    for node in nodes:
      result += ")"
    return result

  def visit_Num(self, node):
    if type(node.n) is int or type(node.n) is float:
      return "# " + str(node.n) + "(.List{K})"

  def visit_Str(self, node):
    if type(node.s) is str:
      return '# "' + self.getstr(node.s, self.convert) + '"(.List{K})'

  @staticmethod
  def getstr(s, convert):
    result = repr("'\"" + s)[4:-1].replace('"', '\\"')
    return re.sub("\\\\x([0-9a-f]{2})", convert, result)

  @staticmethod
  def convert(match):
    return "\\" + oct(int("0x" + match.group(1)))

  def visit_Attribute(self, node):
    return "'_._(" + self.visit(node.value) + ",," + self.getid(node.attr) + ")"

  def visit_Subscript(self, node):
    (type, body) = self.visit(node.slice)
    if type == 0:
      # index
      return "'_`[_`](" + self.visit(node.value) + ",," + body + ")"

  def visit_Name(self, node):
    return self.getid(node.id)

  @staticmethod
  def getid(s):
    return '# #id("' + s + '")(.List{K})'

  def visit_List(self, node):
    return "'`[_`](" + self.visit_list(node.elts, "'_`,_", ",") + ")"

  def visit_Tuple(self, node):
    return "'tuple`(_`)(" + self.visit_list(node.elts, "'_`,_", ",") + ")"

  def visit_Index(self, node):
    return (0, self.visit(node.value))

  def visit_And(self, node):
    return "'_and_"
  def visit_Or(self, node):
    return "'_or_"
  def visit_Add(self, node):
    return "'_+_"
  def visit_Sub(self, node):
    return "'_-_"
  def visit_Mult(self, node):
    return "'_*_"
  def visit_Div(self, node):
    return "'_/_"
  def visit_Mod(self, node):
    return "'_%_"
  def visit_Pow(self, node):
    return "'_**_"
  def visit_LShift(self, node):
    return "'_<<_"
  def visit_RShift(self, node):
    return "'_>>_"
  def visit_BitOr(self, node):
    return "'_|_"
  def visit_BitXor(self, node):
    return "'_^_"
  def visit_BitAnd(self, node):
    return "'_&_"
  def visit_FloorDiv(self, node):
    return "'_floor/_"
  def visit_Invert(self, node):
    return "'~_"
  def visit_Not(self, node):
    return "'not_"
  def visit_UAdd(self, node):
    return "'+_"
  def visit_USub(self, node):
    return "'-_"
  def visit_Eq(self, node):
    return "'_==_"
  def visit_NotEq(self, node):
    return "'_!=_"
  def visit_Lt(self, node):
    return "'_<_"
  def visit_LtE(self, node):
    return "'_<=_"
  def visit_Gt(self, node):
    return "'_>_"
  def visit_GtE(self, node):
    return "'_>=_"
  def visit_Is(self, node):
    return "'_is_"
  def visit_IsNot(self, node):
    return "'_is`not_"
  def visit_In(self, node):
    return "'_in_"
  def visit_NotIn(self, node):
    return "'_not`in_"

input = "".join(sys.stdin.readlines())
print(KPythonVisitor().visit(ast.parse(input)))
