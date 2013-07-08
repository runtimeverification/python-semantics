class A: pass
a = A()
class B(str): pass
b = B()
a.x = 5
assert a.x == 5
b.x = 5
assert b.x == 5
