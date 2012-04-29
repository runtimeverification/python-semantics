def c():
  global x
  try:
    x = 11
    return 5
    assert False
  finally:
    assert x == 11
    x = 12
    return 6
    assert False
  assert False

assert c() == 6
assert x == 12
