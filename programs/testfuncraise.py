x = 5
def b():
  global x
  try:
    assert x == 5
    x = 6
    raise
    assert False
  finally:
    assert x == 6
    x = 7
  assert False

try:
  assert b() and False
except RuntimeError:
  assert x == 7
  x = 8

assert x == 8
