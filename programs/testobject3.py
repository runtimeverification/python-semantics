a = object()
b = str()
try:
  a.x = 5
  assert False
except AttributeError:
  try:
    b.x = 5
    assert False
  except AttributeError: pass
