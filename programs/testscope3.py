def a():
  x = 5
  def b():
    def c():
      assert x == 5
    c()
  assert "x" in b.__code__.co_freevars
  b()
  def d():
    def e():
      x = 6
      assert x == 6
    e()
  assert "x" not in d.__code__.co_freevars
  assert "x" not in d.__code__.co_cellvars
  d()
a()
