class A:
  def __lt__(self, other):
    return True

assert A() < A()
assert A() > A()
