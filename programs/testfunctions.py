def a(x, y):
  assert x == 1 and y == 2

z = [1, 2]
assert a(* z) is None

try:
  a(* 5)
  assert False
except TypeError:
  x = 5
assert x == 5

def b(* x):
  assert x[0] == 5 and x[1] == 6 and len(x) == 2, x[0] + x[1]

assert b(5, 6) is None

def c(): pass

try:
  c(1)
  assert False
except TypeError:
  x = 6
assert x == 6

def d(x, y, ** z):
  assert x == 5 and y == 6 and z["w"] == 7 and len(z) == 1
  return 0

assert d(y=6,x=5,w=7) == 0
