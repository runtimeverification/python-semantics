def a(* x, **y):
  assert x == ()
  assert y == {}

assert a() is None
