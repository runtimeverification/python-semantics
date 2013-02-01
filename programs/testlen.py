assert len([0, 1]) == 2
assert len("foo") == 3
assert len("\u2020\u2020") == 2

class A:
  def __len__(self): return "5"
  def __index__(self): return 2

class B:
  def __len__(self): return -1

try:
  len(5)
  assert False
except TypeError:
  try:
    len(A())
    assert False
  except TypeError:
    try:
      len(B())
      assert False
    except ValueError:
      x = 5

assert x == 5

class C:
  def __len__(self): return A()

assert len(C()) == 2
