class A(Exception):
  def __init__(self):
    assert not foo.gi_running
    assert next(foo) == 1

def a():
  try:
    yield 1
  except A:
    assert foo.gi_running
    yield 2

foo = a()
assert foo.throw(A) == 2
