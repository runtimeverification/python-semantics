try:
  def a():
    try:
      raise ValueError
    except ValueError:
      yield 5
      raise
  b=a()
  b.__next__()
  raise
except RuntimeError:
  x = 5
assert x == 5

try:
  b.__next__()
except ValueError:
  x = 6
assert x == 6
