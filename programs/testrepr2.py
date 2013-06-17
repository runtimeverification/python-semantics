class A:
  def __init__(self, x): self.x = x
  def __repr__(self):  return self.x

assert repr(A("foo")) == "foo"
try:
  repr(A(5))
  assert False
except TypeError: pass
