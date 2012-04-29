try:
  try:
    raise
    assert False
  except a:
    assert False
except NameError:
  x = 9
assert x == 9
