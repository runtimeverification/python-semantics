x = 3
y = 1
while x > 0:
  x = x - 1
  try:
    continue
    assert False
  finally:
    y = y + 1
  assert False
assert y == 4
