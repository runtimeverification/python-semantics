class A:
  def __setattr__(self, name, value):
    assert name == "x"
    assert self.__class__ is A
    assert value == 5

a = A()
a.x = 5
try:
  a.x
  assert False
except AttributeError: pass
