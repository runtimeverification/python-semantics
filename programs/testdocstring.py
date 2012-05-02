"5"

assert __doc__ == "5"

def a():
  "5"

assert a.__doc__ == "5"

def b():
  "5"
  return 5

assert b.__doc__ == "5"

def c(): pass

assert c.__doc__ is None

def d():
  b"5"

assert d.__doc__ is None

def e():
  "5" + "6"

assert e.__doc__ is None

def f():
  x = 5
  y = 6

assert f.__doc__ is None
