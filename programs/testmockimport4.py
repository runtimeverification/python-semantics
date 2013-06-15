def __import__(name, globals=None, locals=None, fromlist=(), level=0):
  assert name == "foo.bar.baz"
  assert fromlist is None
  assert level == 0
  class A: pass
  a = A()
  a.foo = 1
  a.bar = A()
  a.bar.baz = 2
  return a

x = 0
import builtins
builtins.__import__ = __import__
import foo.bar.baz
assert foo.foo == 1
import foo.bar.baz as bar
assert bar == 2
