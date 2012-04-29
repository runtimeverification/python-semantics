x = True
def f(y=[]):
  if x: assert y == []
  else: assert y == [5]
  list.__init__(y, [5])

assert f() is None
x = False
assert f() is None
assert f([5]) is None
