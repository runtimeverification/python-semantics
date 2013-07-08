class A:
  def __lt__(self, other): return True

class B(A):
  def __init__(self, x): self.x = x
  def __gt__(self, other):
    if self.x == 5:
      return NotImplemented
    else:
      return False

a = A()
b1 = B(1)
b5 = B(5)
assert a < a
assert a < b5
assert b5 > a
assert not a < b1
assert not b1 > a
