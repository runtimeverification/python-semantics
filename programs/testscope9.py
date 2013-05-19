class A:
  def a(self):
    assert __class__ is A

A().a()

assert "__class__" in A.a.__code__.co_freevars
