def a():
  assert (yield 5) == 5
  assert (yield 6) == 6
  return 7

b = a()
assert b.__next__() == 5
assert b.send(5) == 6
try:
  b.send(6)
  assert False
except StopIteration as e:
  assert e.args == (7,)
