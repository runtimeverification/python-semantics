def f():
  try: 
    raise ValueError
  finally:
    return 5
try:
  assert f() == 5
  raise
except RuntimeError:
  x = 5
assert x == 5
