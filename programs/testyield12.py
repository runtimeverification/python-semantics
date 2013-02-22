def a():
  yield 5
  return

b=a()

assert b.__next__() == 5
try:
  b.__next__()
  assert False
except StopIteration:
  try:
    b.__next__()
    assert False
  except StopIteration: 
    x = 5
assert x == 5
