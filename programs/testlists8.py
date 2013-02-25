class A:
  def __index__(self):
    return 1

assert [1, 2][A()] == 2
assert (1, 2)[A()] == 2
