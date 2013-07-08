class A:
  def __bool__(self): return x

x = False
assert not bool(A())
x = True
assert bool(A())
