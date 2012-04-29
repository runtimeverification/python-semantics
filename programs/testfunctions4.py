def d(x, y, ** z):
  assert x == 5 and y == 6 and z["w"] == 7 and len(z) == 1, (x, y, z)
  return 0

assert d(y=6,x=5,w=7) == 0

try:
  d(1, 2, x=2)
  assert False
except TypeError:
  x = 7
assert x == 7
