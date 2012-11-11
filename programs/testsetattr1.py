class A: pass

A.x = 5
assert A.x == 5
setattr(A, "x", 6)
assert A.x == 6

a = A()
assert a.x == 6
a.x = 7
assert a.x == 7
assert A.x == 6
setattr(a, "x", 8)
assert a.x == 8
assert A.x == 6
