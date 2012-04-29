try:
  x = (5,6).__iter__()
  assert x.__next__() is 5
  assert x.__next__() is 6
  y = 5
  assert x.__next__() and False
except StopIteration as e:
  z = 6
  assert y == 5
  assert e.__context__ is None
assert z == 6
