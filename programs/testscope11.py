class A:
  __class__ = 5
  def foo(self): assert __class__ is A

A().foo()
