def a(): pass

x = 5
a.__module__ = x
assert a.__module__ is x == 5

x = 6
setattr(a, "__module__", x)
assert a.__module__ is x == 6
