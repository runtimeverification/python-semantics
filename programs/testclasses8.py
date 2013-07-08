class A(int):
  def __new__(cls, foo, bar, baz):
    return 5
    assert foo == "foo"
    assert bar == "bar"
    assert baz == "baz"
  def __init__(self, foo, bar, baz):
    assert self.__class__ is A
    assert foo == "foo"
    assert bar == "bar"
    assert baz == "baz"

assert A("foo", "bar", "baz") == 5
