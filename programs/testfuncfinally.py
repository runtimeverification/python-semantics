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

def b():
  global x
  try:
    x = 9
    return 5
    assert False
  finally:
    assert x == 9
    x = 10
  assert False

assert b() == 5
assert x == 10
