assert None.__ne__(5)
assert None != 5

try:
  class A(None.__class__): pass
  assert False
except TypeError: pass

assert None.__class__() is None
