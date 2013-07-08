import sys

def getframe():
  try:
    raise
  except RuntimeError:
    return sys.exc_info()[2].tb_frame.f_back

z = 5
def a():
  x = 5
  y = 5
  w = 5
  class A:
    nonlocal x
    global z
    x = 6
    f = getframe()
    y = 6
    z = 6
    w = 6
    def foo(self): return y
  assert x == 6
  assert y == 5
  assert z == 6
  assert w == 5
  return A

b = a().f.f_code
assert len(b.co_freevars) == 2
assert 'x' in b.co_freevars
assert 'y' in b.co_freevars
assert 'w' in b.co_names
assert 'z' in b.co_names
