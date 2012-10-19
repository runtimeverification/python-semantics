class M(type): pass

class A(metaclass=M): pass

assert A.__class__ is M
