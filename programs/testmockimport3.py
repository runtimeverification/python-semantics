def __import__(name, globals=None, locals=None, fromlist=(), level=0):
  assert name == ""
  assert fromlist == ("foo",)
  assert level == 1
  class A: pass
  a = A()
  a.foo = 5
  return a

import builtins
builtins.__import__ = __import__
from . import foo
assert foo == 5
