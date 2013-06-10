class A:
  def keys(self): return ()
  
def a():
  x = 5
  def b(): 
    return x
  exec(b.__code__)

def c(d): pass

try:
  exec("5", {}, 5)
  assert False, 0
except TypeError:
  try:
    exec("5", A())
    assert False, 1
  except TypeError:
    try:
      a()
      assert False, 2
    except TypeError:
      try:
        exec(c.__code__)
        assert False, 3
      except TypeError: pass
