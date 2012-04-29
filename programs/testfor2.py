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
