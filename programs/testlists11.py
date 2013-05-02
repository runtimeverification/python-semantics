x = [1, 2, 3, 4, 5]
x[0] = "1"
x[-2] = "4"

assert x == ["1", 2, 3, "4", 5]
try:
  x[6] = 4
except IndexError:
  try:
    x[-10] = 4
  except IndexError:
    y = 5

assert y == 5
