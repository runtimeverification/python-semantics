class A:
  def __ior__(self, other):
    global x
    x = 5

c = {"foo" : A()}
def b():
  global x
  x += 1
  assert x == 1
  return  c
x = 0
b()["foo"] |= A()
assert x == 5
