def a(*x): assert x == (); return 5
def b(**x): assert x == {}; return 5
def c(*x, **y):
  assert x == ()
  assert y == {}
  return 5

assert eval(a.__code__) == 5
assert eval(b.__code__) == 5
assert eval(c.__code__) == 5
assert exec(a.__code__) is None
assert exec(b.__code__) is None
assert exec(c.__code__) is None
