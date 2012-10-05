x = 5
def a():
  x = 6 
  assert x == 6
  def b():
    global x
    assert x == 5
    def c():
      assert x == 5
    c()
    assert "x" in c.__code__.co_names
  b()
  assert "x" in b.__code__.co_names
a()
assert "x" in a.__code__.co_varnames
