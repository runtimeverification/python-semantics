def __import__(name, globals=None, locals=None, fromlist=(), level=0):
  assert name == "foo"
  assert fromlist == ("*",)
  assert level == 0
  class A: pass
  a = A()
  a.x = 5
  a._foo = 6
  a.__foo__ = 7
  return a

import builtins
builtins.__import__ = __import__
from foo import *
assert x == 5
try:
  _foo
  assert False
except NameError:
  try:
    __foo__
    assert False
  except NameError: pass
