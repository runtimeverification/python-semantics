for x in (0, 1, 2, 3):
  for y in (4, 5, 6, 7):
    if y == 5:
      break
    assert y <= 5
  z = x
assert z == 3
