try:
  "5" .__add__(6)
  assert False
except TypeError:
  x = 5
assert x == 5
