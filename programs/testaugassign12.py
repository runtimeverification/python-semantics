class A:
  def __ior__(self, other):
    global x
    x = 5

y = A()
y |= A()
assert x == 5
