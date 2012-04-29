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
