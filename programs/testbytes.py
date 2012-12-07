assert b"foo" > b"fo" >= b"f"
assert not b"foo" > b"foo"
assert b"foo" >= b"foo"
assert b"f" <= b"fo" < b"foo"
assert not b"foo" < b"foo"
assert b"foo" <= b"foo"
assert b"foo" == b"foo" != b"fo"

assert b"f" * 5 == b"fffff" == b"f" . __mul__(5) == b"f" . __rmul__(5)
assert bytes(5) == b"\0\0\0\0\0"

try:
  bytes("foo")
  assert False
except TypeError:
  x = 5
assert x == 5

class A:
  def __init__(self): self.x = 5
  def __iter__(self): return self
  def __next__(self):
    self.x -= 1
    if self.x == 0:
      raise StopIteration
    return self.x

assert bytes(A()) == b"\x04\x03\x02\x01"
