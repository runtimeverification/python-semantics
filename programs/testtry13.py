try:
  raise None
  assert False
except TypeError:
  x = 13
assert x == 13

try:
  raise SyntaxError from None
  assert False
except TypeError:
  x = 14
assert x == 14
