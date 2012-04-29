x = 3
while x > 0:
  x = x - 1
  y = 3
  while y > 0:
    y = y - 1
    if y == 2: break
    assert y >= 2
  z = x
assert z == 0
