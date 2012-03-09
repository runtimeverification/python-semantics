def a(x, y):
  assert x == 1 and y == 2

z = [1, 2]
assert a(* z) is None

try:
  a(* 5)
  assert False
except TypeError:
  x = 3
assert x == 3

try:
  a(1, 2, 3)
  assert False
except TypeError:
  x = 4
assert x == 4

def b(* x):
  assert x[0] == 5 and x[1] == 6 and len(x) == 2, x[0] + x[1]

assert b(5, 6) is None

def c(): pass

try:
  c(1)
  assert False
except TypeError:
  x = 5
assert x == 5

try:
  c(x=5)
  assert False
except TypeError:
  x = 6
assert x == 6

def d(x, y, ** z):
  assert x == 5 and y == 6 and z["w"] == 7 and len(z) == 1, (x, y, z)
  return 0

assert d(y=6,x=5,w=7) == 0

try:
  d(1, 2, x=2)
  assert False
except TypeError:
  x = 7
assert x == 7

def e(*, x, y): assert x == 5 and y == 6

try:
  e()
  assert False
except TypeError:
  x = 8
assert x == 8

assert e(x=5,y=6) is None

x = True
def f(y=[]):
  if x: assert y == []
  else: assert y == [5]
  list.__init__(y, [5])

assert f() is None
x = False
assert f() is None
assert f([5]) is None
