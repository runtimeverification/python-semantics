assert all(()) is True
assert all((1,)) is True
assert all((0,)) is False
assert all((1,2,3,4)) is True
assert all((1,2,3,4,0)) is False

class A:
  x = 0
  def __bool__(self): A.x += 1; return False

assert not all((A(), A(), A(), A()))
assert A.x == 1
