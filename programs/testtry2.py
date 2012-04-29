try:
  raise
  assert False
except RuntimeError:
  x = 6
finally:
  y = 7
  assert x == 6
assert y == 7
