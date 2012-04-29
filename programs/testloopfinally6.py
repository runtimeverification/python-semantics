for x in (2, 3, 4):
  try:
    break
    assert False
  finally:
    y = 6
    assert x == 2
  assert False
assert y == 6
