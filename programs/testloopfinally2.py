x = 6
while x > 0:
  try:
    break
    assert False
  finally:
    y = 7
    assert x == 6
  assert False
assert y == 7
