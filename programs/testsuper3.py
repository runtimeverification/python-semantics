class A:
  def a(self, cls):
    s = super()
    assert s.__self__ is self
    assert self.__class__ is cls
    assert s.__thisclass__ is __class__ is A
    assert s.__self_class__ is cls

  def b(self):
    self.x = 5

class B(A): pass

A().a(A)
B().a(B)

class C:
  @classmethod
  def a(cls):
    s = super()
    assert s.__self__ is cls
    assert cls.__class__ is type
    assert s.__thisclass__ is __class__ is C
    assert s.__self_class__ is cls

C().a()

class D(A):
  def c(self):
    super().b()

  def b(self):
    assert False

d = D()
d.c()
assert d.x == 5
