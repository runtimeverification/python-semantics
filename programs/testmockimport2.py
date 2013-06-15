def __import__(name, globals=None, locals=None, fromlist=(), level=0):
  assert name == "foo"
  assert fromlist == ("*",)
  assert level == 0
  class A: pass
  a = A()
  a.x = 5
  a._foo = 6
  a.__foo__ = 7
  a.__all__ = ("__foo__",)
  return a

import builtins
builtins.__import__ = __import__
from foo import *
assert __foo__ == 7
try:
  x
  assert False
except NameError:
  try:
    _foo
    assert False
  except NameError:
    pass
