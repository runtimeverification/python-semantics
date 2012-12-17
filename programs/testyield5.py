def a():
  try:
    try:
      yield 5
      raise TypeError
    except TypeError:
      yield 6
  finally:
    yield 7

assert list(a()) == [5, 6, 7]
