try:
  raise TypeError
except TypeError as e:
  del e
