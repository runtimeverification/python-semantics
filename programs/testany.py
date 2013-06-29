assert any(()) is False
assert any((1,)) is True, any((1,))
assert any((0,)) is False
assert any((0, 0, 0, 0)) is False
assert any((0, 0, 0, 1)) is True

class A:
  x = 0
  def __bool__(self): A.x += 1; return True

assert any((A(), A(), A(), A()))
assert A.x == 1
