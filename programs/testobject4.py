class A: pass

a = object.__new__(A)
a.x = 5
assert a.x == 5

class B(int): pass

try:
  b = object.__new__(B)
  assert False
except TypeError:
  try:
    b = object.__new__(int)
    assert False
  except TypeError: pass
