assert True # should succeed
try:
  assert False # should raise AssertionError
except AssertionError:
  x = 5
assert x == 5
