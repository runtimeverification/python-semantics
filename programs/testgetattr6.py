class A:
  def __str__(self): raise TypeError
  def __format__(self, spec): raise TypeError
  def __hash__(self): raise TypeError
  def __bool__(self): raise TypeError
  def __eq__(self): raise TypeError
def assertRaises(error, call, *args):
  try:
    call(*args)
    assert False
  except error: pass

a = A()
a.__str__ = lambda self: "foo"
a.__format__ = lambda self, spec: "foo"
a.__eq__ = lambda self, other: True
a.__hash__ = lambda self: 0
a.__bool__ = lambda self: True
a.__call__ = lambda self: 0
a.__len__ = lambda self: 0
a.__getitem__ = lambda self, key: 0
a.__iter__ = lambda self: iter([])
a.__reversed__ = lambda self: []
a.__contains__ = lambda self, item: True
a.__add__ = lambda self, other: 5
a.__rsub__ = lambda self, other: 5
a.__imul__ = lambda self, other: 5
a.__neg__ = lambda self: 5
a.__int__ = lambda self: 5
a.__index__ = lambda self: 5
a.__enter__ = lambda self: self
a.__exit__ = lambda self, t, value, tb: False
assertRaises(TypeError, str, a)
assertRaises(TypeError, format, a, "foo")
assertRaises(TypeError, lambda: a == 5)
assertRaises(TypeError, hash, a)
assertRaises(TypeError, bool, a)
assertRaises(TypeError, a)
assertRaises(TypeError, len, a)
assertRaises(TypeError, lambda: a[5])
assertRaises(TypeError, iter, a)
assertRaises(TypeError, reversed, a)
assertRaises(TypeError, lambda: 5 in a)
assertRaises(TypeError, lambda: a + 5)
assertRaises(TypeError, lambda: 5 - a)

def b():
  global a
  a *= 2
assertRaises(TypeError, b)
assertRaises(TypeError, lambda: -a)
assertRaises(TypeError, int, a)
class B:
  def __len__(self): return a
assertRaises(TypeError, len, B())

try:
  with a as c: pass
  assert False
except AttributeError: pass
