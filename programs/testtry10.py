try:
  try:
    raise
    assert False
  finally:
    x = 11
  assert False
except RuntimeError:
  y = 12
  assert x == 11
assert y == 12
