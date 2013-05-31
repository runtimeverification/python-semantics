import _io
i = _io._RawIOBase()
i.close()
try:
  i.read()
except AttributeError:
  try:
    i.read(-1)
  except AttributeError:
    try:
      i.readall()
    except AttributeError:
      x = 5

assert x == 5
