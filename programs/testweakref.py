import _weakref
import gc

class A:
  pass

def p(weakref):
  global x
  assert weakref() is None
  x += 1

x = 0
w1 = _weakref.ref(A())
gc.collect()
assert x == 0
assert w1() is None
a = A()
w2 = _weakref.ref(a)
w3 = _weakref.ref(a, p)
w4 = _weakref.ref(a, p)
del a
gc.collect()
assert x == 2
