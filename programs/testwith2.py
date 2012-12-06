class A:
  def __enter__(self): 
    global x
    x = 0
  def __exit__(self, type, value, traceback):
    global x
    assert x == 1
    x = 2

class B:
  def __enter__(self): 
    global x
  def __exit__(self, type, value, traceback):
    global x
    assert x == 0
    x = 1
    assert type is value.__class__ is RuntimeError
    assert traceback.tb_next is None
    return True

with A(), B(): y = 5; raise
assert y == 5
