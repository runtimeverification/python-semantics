x = 5
def a():
  x = 6
  assert x == 6
a()
assert "x" in a.__code__.co_varnames

def b():
  x = 6
  def c():
    assert x == 6
  assert x == 6
  c()
  assert "x" in c.__code__.co_freevars
b()
assert "x" in b.__code__.co_cellvars

a = 7
def c():
  def d():
    assert a == 7
  d()
  assert "a" in d.__code__.co_names
c()
