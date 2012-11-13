try:
  x = iter((5,6))
  assert x.__next__() == 5
  assert x.__next__() == 6
  y = 6
  assert x.__next__() and False
except StopIteration as e:
  z = 7
  assert y == 6
  assert e.__context__ is None
assert z == 7
