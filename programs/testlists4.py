try:
  [5,6][-3]
  assert False
except IndexError:
  x = 6
assert x == 6
