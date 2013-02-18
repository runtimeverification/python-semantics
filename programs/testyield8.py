def a():
  try:
    yield 5
    assert False
  except GeneratorExit:
    yield 6
    assert False

b = a()
b.__next__()
try:
  b.close()
except RuntimeError:
  x = 5
assert x == 5
