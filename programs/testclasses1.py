class A:
  x = 5

assert A.__doc__ is None
assert A.__module__ == "__main__"
assert A.__name__ == "A"
assert A.__bases__ == (object,)
assert A.__mro__ == (A, object)
assert A.x == 5

class B(int, A): pass

assert B.__bases__ == (int, A)
assert B.__mro__ == (B, int, A, object)

class C(B, * (int, A)): pass

assert C.__bases__ == (B, int, A)
assert C.__mro__ == (C, B, int, A, object)
