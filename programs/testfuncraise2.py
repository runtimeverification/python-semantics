def a():
  raise ValueError

try:
  try:
    raise
  except RuntimeError:
    a()
except ValueError as e:
  assert e.__context__.__class__ == RuntimeError
  x = 5
assert x == 5
