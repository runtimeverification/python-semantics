try:
  1/0
except ZeroDivisionError:
  try:
    1%0
  except ZeroDivisionError:
    try:
      1//0
    except ZeroDivisionError:
      try:
        0 ** -1
      except ZeroDivisionError:
        x = 1
assert x == 1
