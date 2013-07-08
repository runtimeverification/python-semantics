class A:
  def __iter__(self):
    global x
    assert x == 0
    x += 1
    return self
  def __next__(self): return 5

x = 0
a = A()
iter(a)
