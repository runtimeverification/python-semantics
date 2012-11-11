class A:
  def __get__(self, instance, owner): assert self.__class__ is A and instance is None and owner is B; return 5

class B:
  x = A()

assert B.x == 5
assert getattr(B, "x") == 5
