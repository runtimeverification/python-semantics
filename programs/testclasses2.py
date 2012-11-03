class M(type): pass

class A(metaclass=M): pass

assert A.__class__ is M

class B(A, metaclass=type): pass

assert B.__class__ is M

