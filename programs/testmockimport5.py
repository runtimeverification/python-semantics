def __import__(name, globals=None, locals=None, fromlist=(), level=0):
  class A: pass
  a = A()
  return a

import builtins
builtins.__import__ = __import__
try:
  from foo import a
  assert False
except ImportError: pass
