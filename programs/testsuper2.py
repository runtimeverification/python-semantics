try:
  super(int, "5")
except TypeError:
  try:
    super("5")
  except TypeError:
    x = 5

assert x == 5
