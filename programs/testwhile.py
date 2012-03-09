x = 3
while x > 0:
  x = x - 1
else:
  y = 6
  assert x == 0
assert y == 6

x = 4
y = 7
while x > 0:
  x = x - 1
  if x == 3:
    continue
  assert x != 3
  if x == 2:
    break
  assert x >= 2
else:
  assert False
assert y == 7 and x == 2

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
