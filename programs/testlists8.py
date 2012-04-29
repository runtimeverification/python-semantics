x = iter([5,6])
assert x.__next__() == 5
assert x.__next__() == 6
try:
  assert x.__next__() and False
except StopIteration:
  y = 5
assert y == 5
