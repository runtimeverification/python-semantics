x = 5
try:
  while x > 0:
    try:
      raise
    finally:
      y = 6
      assert x == 5
    assert False
  assert False
except RuntimeError:
  z = 7
  assert y == 6
assert z == 7
