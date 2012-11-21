class A:
  def __get__(self, instance, owner): assert self.__class__ is A and instance.__class__ is B and owner is B, (self, instance, owner); return 5

class B:
  x = A()

b = B()
assert b.x == 5
assert getattr(b, "x") == 5
assert hasattr(b, "x")

b.x = A()
assert b.x.__class__ is A
assert getattr(b, "x").__class__ is A
assert hasattr(b, "x")

A.__set__ = lambda self, instance, value: None

assert b.x == 5
assert getattr(b, "x") == 5
assert hasattr(b, "x")
