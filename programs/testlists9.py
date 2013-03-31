x = [1, 2, 3]
x.extend((4, 5, 6))
assert x == [1, 2, 3, 4, 5, 6]
try:
  x.extend(5)
except TypeError:
  y = 5
assert y == 5
