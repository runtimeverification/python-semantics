for x in (1, 2, 3, 4):
  for y in (5, 6, 7, 8):
    if y == 6: continue
    assert y != 6
    if y == 7:
      z = 4
  z = z + 1
assert z == 5
