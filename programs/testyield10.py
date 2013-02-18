def a():
  try:
    yield 5
  except GeneratorExit:
    raise TypeError

b = a()
b.__next__()
try:
  b.close()
except TypeError:
  x = 5
assert x == 5
