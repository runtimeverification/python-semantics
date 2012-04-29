def c(): pass

try:
  c(1)
  assert False
except TypeError:
  x = 5
assert x == 5

try:
  c(x=5)
  assert False
except TypeError:
  x = 6
assert x == 6
