class A: pass

A.x = 5
assert A.x == 5

a = A()
assert a.x == 5
a.x = 6
assert a.x == 6
assert A.x == 5
