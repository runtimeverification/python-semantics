def a():
  try:
    yield 5
    assert False
  except GeneratorExit:
    raise StopIteration

b = a()
b.__next__()
b.close()
try:
  b.__next__()
except StopIteration:
  x = 5
assert x == 5
