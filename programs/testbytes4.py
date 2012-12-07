class A:
  def __init__(self): self.x = 5
  def __iter__(self): return self
  def __next__(self):
    self.x -= 1
    if self.x == 0:
      raise StopIteration
    return self.x

assert bytes(A()) == b"\x04\x03\x02\x01"
