assert len([5]) == 1
assert len([5,6]) == 2

assert [5,6][0] == 5
assert [5,6][1] == 6
assert [5,6][-1] == 6
assert [5,6][-2] == 5

try:
  [5,6][2]
  assert False
except IndexError:
  x = 5
assert x == 5

try:
  [5,6][-3]
  assert False
except IndexError:
  x = 6
assert x == 6

assert [True] == [1]
assert not [] == [1]
assert not [1] == []
assert not [5] == [6]

x = iter([5,6])
assert x.__next__() == 5
assert x.__next__() == 6
try:
  assert x.__next__() and False
except StopIteration:
  y = 5
assert y == 5

assert list((5,)) == [5]
