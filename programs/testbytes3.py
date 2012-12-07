try:
  bytes("foo")
  assert False
except TypeError:
  x = 5
assert x == 5
