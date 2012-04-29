try:
  for x in (1, 2, 3):
    try:
      raise
    finally:
      y = 5
      assert x == 1
    assert False
  assert False
except RuntimeError:
  z = 6
  assert y == 5
assert z == 6
