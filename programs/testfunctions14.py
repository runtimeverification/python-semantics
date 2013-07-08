import types

try:
  class A(types.FunctionType): pass
  assert False
except TypeError: pass
