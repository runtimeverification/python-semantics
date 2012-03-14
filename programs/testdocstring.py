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
