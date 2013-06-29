assert not callable(5)
def a(): pass
assert callable(a)
class A:
  def __call__(self): pass

assert callable(A())
