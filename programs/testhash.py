assert str.__hash__("5").__class__ is int

class A(str):
  __eq__ = 5

assert A.__hash__ is None
