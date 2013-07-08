class A:
  def __lt__(self, other): return NotImplemented
  def __le__(self, other): return None

a = A()

try:
  a < a
  assert False
except TypeError: pass

assert (a <= a) is None

class B(A):
  def __gt__(self, other): return True

b = B()

assert b > a
assert a < b
