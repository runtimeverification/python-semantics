class A:
  def __eq__(self, other):
    return self.x == other.x
  def __init__(self, x):
    self.x = x

assert A(0) == A(0)
assert not(A(0) == A(1))
assert A(1) != A(0)
assert not(A(1) != A(1))
