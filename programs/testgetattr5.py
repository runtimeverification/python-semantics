class A:
  def __getattribute__(self, key): assert False

try:
  getattr(A(), 5)
except TypeError:
  try:
    object.__getattribute__(5, 5)
  except TypeError:
    try:
      type.__getattribute__(int, 5)
    except TypeError:
      try:
        super.__getattribute__(super(bool, True), 5)
      except TypeError:
        x = 5

assert x == 5
