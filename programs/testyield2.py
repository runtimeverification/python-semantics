def c():
  try:
    yield 5
    assert False
  except ValueError:
    yield 6

d = c()
assert d.__next__() == 5
assert d.throw(ValueError) == 6
try:
  d.__next__()
  assert False
except StopIteration as e:
  assert e.args == ()
