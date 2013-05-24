x = reversed([2, 1, 0])
assert x.__next__() == 0
assert x.__next__() == 1
assert x.__next__() == 2
try:
  x.__next__()
  assert False
except StopIteration:
  y = 5
assert y == 5
