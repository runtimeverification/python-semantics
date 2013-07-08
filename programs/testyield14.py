def a():
  yield 1
  next(foo)

foo = a()
next(foo)
try:
  foo.throw(TypeError)
  assert False
except ValueError: assert False
except TypeError: pass
