try:
  try:
    raise
    assert False
  finally:
    try:
      raise TypeError
      assert False
    except TypeError as e:
      assert e.__context__.__class__ == RuntimeError
      x = 10
  assert False
except RuntimeError:
  y = 11
  assert x == 10
assert y == 11
