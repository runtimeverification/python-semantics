i = ImportError(1, 2, 3, name=4, path=5)

assert i.args == (1, 2, 3)
assert i.name == 4
assert i.path == 5

try:
  ImportError(foo=5)
  assert False
except TypeError:
  x = 5
assert x == 5
