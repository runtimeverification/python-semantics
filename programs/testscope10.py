def a():
  def b():
    return x
  def c():
    def d():
      return x
    return d
  x = 5
  d = c()
  return b, c, d

b, c, d = a()
assert b.__closure__[0] is c.__closure__[0] is d.__closure__[0]
