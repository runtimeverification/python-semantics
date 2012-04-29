x = 5

def a():
  global x
  assert x == 5
  x = 6
  return 5

try:
  assert a() == 5
  assert x == 6
  x = 7
finally:
  assert x == 7
  x = 8
assert x == 8
