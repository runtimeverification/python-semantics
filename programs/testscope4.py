x = 5
def a():
  global x
  x = 6
a()
assert x == 6, x
assert "x" in a.__code__.co_names

def b():
  x = 7
  def c():
    nonlocal x
    x = 8
  c()
  assert x == 8
  assert "x" in c.__code__.co_freevars
b()
assert x == 6
assert "x" in b.__code__.co_cellvars
