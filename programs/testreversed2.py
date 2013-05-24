class A:
  def __getitem__(self, idx): return idx

try:
  reversed(5)
  assert False, 5
except TypeError:
  try:
    reversed(A())
    assert False, "A"
  except TypeError:
    A.__len__ = lambda self: 2
    assert list(reversed(A())) == [1, 0]
    x = 5
assert x == 5
