x = 3
while x > 0:
  x = x - 1
  y = 4
  while y > 0:
    y = y - 1
    if y == 3: continue
    assert y != 3
    if y == 2:
      z = 2
  z = z + 1
assert z == 3
