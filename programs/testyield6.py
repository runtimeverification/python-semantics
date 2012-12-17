def a():
  try:
    yield 5
    return
  finally:
    yield 6

assert list(a()) == [5, 6]
