try:
  x = 5
except TypeError:
  assert False
except SyntaxError as y:
  assert False
else:
  y = 6
  assert x == 5
finally:
  z = 7
  assert y == 6
assert z == 7
