def f():
  yield 5
  raise ValueError

g = f()
try:
  assert g.__next__() == 5
except ValueError:
  assert False

try:
  g.__next__()
except ValueError:
  x = 6
assert x == 6
