assert isinstance(5, int)
assert isinstance(True, int)
assert not isinstance(5, tuple)

class M(type):
  def __instancecheck__(self, instance):
    return True

class A(metaclass=M): pass

assert isinstance(5, A)
