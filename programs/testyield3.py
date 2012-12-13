def e(foo):
  assert foo == 5
  try:
    return
    yield
  except StopIteration:
    assert False

try:
  e(5).__next__()
  assert False
except StopIteration:
  x = 5
assert x == 5
