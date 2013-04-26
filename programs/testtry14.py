try:
  raise TypeError
except TypeError as e:
  e
  try:
    raise TypeError
  except TypeError as e:
    e
    x = 5
assert x == 5
