class A:
  def __index__(self): return 5

b = b"\x00\x00\x00\x00\x00"
assert bytes(A()) == b

def a():
  yield 256

try:
  bytes(a())
except ValueError:
  try:
    bytearray(a())
  except ValueError:
    x = 5
assert x == 5
