def helper(t):
  try:
    t()
    assert False
  except TypeError: pass

import types

helper(types.GeneratorType)
helper(types.BuiltinFunctionType)
helper(types.TracebackType)
helper(types.FrameType)
helper(types.FunctionType)
helper(types.MethodType)

def a():
  x = 5
  def b(): return x
  return b

CellType = a().__closure__[0].__class__
helper(CellType)
