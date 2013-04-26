try:
  del x
except NameError:
  def a():
    x = 5
    del x
    del x
  try:
    a()
  except UnboundLocalError:
    y = 5

assert y == 5
