x = 5
def a():
  x = 6
  def b():
    return x
  return b

assert a()() == 6, a()()
