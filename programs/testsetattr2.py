try:
  5 . x = 5
  assert False
except AttributeError:
  a = 1
assert a == 1

try:
  int . x = 5
  assert False
except TypeError:
  b = 2
assert b == 2

class A: pass

try:
  object.__setattr__(A, "x", 5)
except TypeError:
  c = 3
assert c == 3
