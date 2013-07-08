try:
  class A(bool): pass
  assert False
except TypeError: pass
