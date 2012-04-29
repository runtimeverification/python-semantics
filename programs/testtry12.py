try:
  try:
    raise SyntaxError
  except SyntaxError:
    try:
      raise TypeError
    except TypeError: pass
    raise
except SyntaxError:
  x = 12
assert x == 12
