def e(*, x, y): assert x == 5 and y == 6

try:
  e()
  assert False
except TypeError:
  x = 8
assert x == 8

assert e(x=5,y=6) is None
