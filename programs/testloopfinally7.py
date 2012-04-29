y = 2
for x in (3, 4, 5):
  try:
    continue
    assert False
  finally:
    y = y + 1
  assert False
assert y == 5
