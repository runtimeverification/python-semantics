import sys

def test():
  foo = 5
  class Test:
    foo = 6
    def bar(self): return foo
    try:
      raise
    except RuntimeError:
      baz = sys.exc_info()[2].tb_frame.f_code
  return Test()
a = test()
assert a.baz.co_freevars == ('foo',)
assert a.bar() == 5
