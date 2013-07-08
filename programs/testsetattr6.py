class A:
  def __get__(self, instance, owner):
    global x
    x += 1
    assert x > 1
    return self
  z = 1

class B:
  y = A()

def c():
  global x
  x += 1
  assert x == 1
  return 2

x = 0

b = B()
b.y.z = c()

assert b.y.z == 2
