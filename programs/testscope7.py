def a():
  x = 5
  def b():
    def c():
      nonlocal x
      assert x == 5
      del x
      try:
        x
        assert False
      except NameError:
        pass
    assert x == 5
    c()
    try:
      x
      assert False
    except NameError:
      pass
  assert x == 5
  b()
  try:
    x
    assert False
  except NameError:
    pass
a()
