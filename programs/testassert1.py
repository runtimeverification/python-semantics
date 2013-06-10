assert True # should succeed
try:
  assert False # should raise AssertionError
  raise TypeError # should not execute
except AssertionError:
  x = 5
assert x == 5
