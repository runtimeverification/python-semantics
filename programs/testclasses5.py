def helper(* t):
  try:
    class A(* t): pass
    assert False
  except TypeError: pass

import types

helper(int, float)
helper(types.GeneratorType)
helper(types.BuiltinFunctionType)
helper(types.TracebackType)
helper(types.CodeType)
helper(types.FrameType)
helper(types.MethodType)
helper(slice)

def a():
  x = 5
  def b(): return x
  return b

CellType = a().__closure__[0].__class__
helper(CellType)
