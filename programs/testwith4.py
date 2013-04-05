class A:
  def __enter__(self): pass
  def __exit__(sef, type, value, traceback):
    return False

def a():
  with A():
    pass

a()
