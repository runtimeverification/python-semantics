x = 1
while x > 0:
  try:
    raise
  finally:
    y = 2
    break
assert y == 2
