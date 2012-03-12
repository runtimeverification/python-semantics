x = 5
assert x == 5

x, y = (6, 5)
assert x == 6 and y == 5

x, y, (z, w) = (1, 2, (3, 4))
assert x == 1 and y == 2 and z == 3 and w == 4

try:
  x, y = 5
except TypeError:
  pass

try:
  x, y, z = 1, 2
except ValueError:
  pass

try:
  x, y = 1, 2, 3
except ValueError:
  pass

a, b, * c, x, y, z = (1, 2, 3, 4, 5, 6, 7, 8, 9)
assert a == 1 and b == 2 and x == 7 and y == 8 and z == 9 and c == [3, 4, 5, 6]

x, *y, z = (1, 2)
assert x == 1 and z == 2 and y == []
