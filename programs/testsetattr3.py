def a(): pass

x = 5
y = "x"
a.__module__ = x
a.__name__ = y
assert a.__module__ is x == 5
assert a.__name__ == y == "x"

x = 6
y = "y"
setattr(a, "__module__", x)
setattr(a, "__name__", y)
assert a.__module__ is x == 6
assert a.__name__ == y == "y"

try:
  a.__name__ = 5
  assert False
except TypeError:
  z = 1
assert z == 1
