x = 0

class A:
  def __enter__(self):
    global x
    assert x == 1
    x += 1
    return 5
  class B:
    def __get__(self, instance, owner):
      global x
      assert x == 0
      x += 1
      def __exit__(type, value, traceback):
        global x
        assert x == 3
        x += 1
        assert type is value is traceback is None
      return __exit__
  __exit__ = B()

with A() as a:
  assert a == 5
  assert x == 2
  x += 1
assert x == 4
