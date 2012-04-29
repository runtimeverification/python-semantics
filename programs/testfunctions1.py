def a(x, y):
  assert x == 1 and y == 2

z = [1, 2]
assert a(* z) is None

try:
  a(* 5)
  assert False
except TypeError:
  x = 3
assert x == 3

try:
  a(1, 2, 3)
  assert False
except TypeError:
  x = 4
assert x == 4
