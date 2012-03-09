assert (5,) is (5,)
assert not ((5,6) is (6,))

assert len((5,)) == 1
assert len((5,6)) == 2
assert len(()) == 0

assert (5,).__add__((6,)) is tuple.__add__((5,),(6,)) is (5,) + (6,) is (5,6)

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

try:
  x = iter((5,6))
  assert x.__next__() is 5
  assert x.__next__() is 6
  y = 6
  assert x.__next__() and False
except StopIteration as e:
  z = 7
  assert y == 6
  assert e.__context__ is None
assert z == 7

try:
  iter(5)
  assert False
except TypeError:
  x = 7
assert x == 7

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

try:
  iter.__class__()
except TypeError:
  x = 9
assert x == 9

assert (5,6)[0] is 5
assert (5,6)[1] is 6
assert (5,6)[-1] is 6
assert (5,6)[-2] is 5

try:
  (5,6)[-3]
  assert False
except IndexError:
  x = 10
assert x == 10

try:
  (5,6)[2]
  assert False
except IndexError:
  x = 11
assert x == 11
