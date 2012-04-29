try:
  x = iter.__class__.__call__(iter, (5,6))
  assert x.__next__() is 5
  assert x.__next__() is 6
  y = 8
  assert x.__next__() and False
except StopIteration as e:
  z = 9
  assert y == 8
  assert e.__context__ is None
assert z == 9
