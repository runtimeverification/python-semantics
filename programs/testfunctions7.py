x = False
def g():
  try:
    a
    assert False
  except UnboundLocalError:
    x = 5
  assert x == 5
  def a():
    nonlocal x
    x = x + 1
  assert a() is None
  assert x == 6
  try:
    e
    assert False
  except UnboundLocalError as e:
    x = 7
  assert x == 7
  return a
assert g()() is None
assert x == False
