try:
  (5,6)[-3]
  assert False
except IndexError:
  x = 10
assert x == 10

try:
  (5,6)[2]
  assert False
except IndexError:
  x = 11
assert x == 11
