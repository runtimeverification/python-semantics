class A:
  def __str__(self): return "foo"

assert str(A()) == "foo"
assert str() == ""
assert str(True) == "True"
assert str(False) == "False"
