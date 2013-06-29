def a():
  yield 5
  yield 6

x = iter(a())
assert next(x) == 5
assert next(x) == 6
try:
  next(x)
  assert False
except StopIteration: pass

assert next(x, 7) == 7
