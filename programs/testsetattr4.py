class A:
  def __set__(self, instance, value): assert self.__class__ is A and instance is b and value == 5, (self, instance, value); instance.y = 6

class B:
  x = A()

b = B()
b.x = 5
b.y == 6
