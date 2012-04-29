try:
  try:
    raise
  except SyntaxError:
    assert False
  finally:
    x = 7
  assert False
except RuntimeError:
  y = 8
  assert x == 7
assert y == 8
