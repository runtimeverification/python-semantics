class A:
  def __init__(self):
    return 5

try:
  A()
  assert False
except TypeError: pass
