class A:
  x = 5

assert A.__doc__ is None
assert A.__module__ == "__main__"
assert A.__name__ == "A"
assert A.__bases__ == (object,)
assert A.x == 5

class B(int, A): pass

assert B.__bases__ == (int, A)

class C(A, * (int, B)): pass

assert C.__bases__ == (A, int, B)
