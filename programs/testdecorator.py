def a(x):
  return lambda: x() + x()

def b(x):
  return lambda: x() - 2

@a
@b
def c():
  return 5

assert c() == 6
