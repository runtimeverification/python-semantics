y = 0
for x in (5,6):
  y = y + 1
else:
  assert x == 6 and y == 2
  z = 1
assert z == 1

for x in (0, 1, 2, 3, 4):
  if x == 2:
    continue
  assert x != 2
  if x == 3:
    break
  assert x <= 3
else:
  assert False
assert x == 3

for x in (0, 1, 2, 3):
  for y in (4, 5, 6, 7):
    if y == 5:
      break
    assert y <= 5
  z = x
assert z == 3

for x in (1, 2, 3, 4):
  for y in (5, 6, 7, 8):
    if y == 6: continue
    assert y != 6
    if y == 7:
      z = 4
  z = z + 1
assert z == 5
