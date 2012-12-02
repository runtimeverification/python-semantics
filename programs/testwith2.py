class A:
  def __enter__(self): 
    self.x = 0
  def __exit__(self, type, value, traceback):
    assert self.x == 0
    self.x = 1
    assert type is value.__class__ is RuntimeError
    assert traceback.tb_next is None
    return True

with A(): y = 5; raise
assert y == 5
