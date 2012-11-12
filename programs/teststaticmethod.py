def a(): pass

class A:
  b = staticmethod(a)

assert a is A.b is A().b, (a, A.b, A().b)
