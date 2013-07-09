class A(str): pass

assert A("foo").__str__().__class__ is str
