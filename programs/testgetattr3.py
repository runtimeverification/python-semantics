class A:
  def __getattr__(self, s):
    return 5

assert not hasattr(A, "x")
try:
  A.x
  assert False
except AttributeError:
  try:
    getattr(A, "x")
    assert False
  except AttributeError:
    y = 4
assert y == 4
assert A().x == 5
assert getattr(A(), "x") == 5
assert hasattr(A(), "x")

try:
  A().__getattribute__("x")
  assert False
except AttributeError:
  x = 5
assert x == 5
