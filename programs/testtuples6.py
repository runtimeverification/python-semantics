try:
  iter(5)
  assert False
except TypeError:
  x = 7
assert x == 7
