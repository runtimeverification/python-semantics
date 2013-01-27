assert issubclass(bool, int)
assert issubclass(bool, object)
assert not issubclass(int, tuple)

class M(type):
  def __subclasscheck__(self, instance):
    return True

class A(metaclass=M): pass

assert issubclass(int, A)
