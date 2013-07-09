class A(int): pass

assert A(5).__int__().__class__ is int
