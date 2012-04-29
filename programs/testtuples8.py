try:
  iter.__class__()
except TypeError:
  x = 9
assert x == 9
