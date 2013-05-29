import _io
i = _io._IOBase()
i.close()
try:
  i.fileno()
except _io.UnsupportedOperation:
  try:
    i.readline(1)
  except AttributeError:
    try:
      i.readlines(0)
    except ValueError:
      try:
        i.seek()
      except _io.UnsupportedOperation:
        try:
          i.tell()
        except _io.UnsupportedOperation:
          try:
            i.truncate()
          except _io.UnsupportedOperation:
            try:
              i.writelines([])
            except ValueError:
              try:
                i.write()
              except AttributeError:
                try:
                  i.read()
                except AttributeError:
                  try:
                    i.readall()
                  except AttributeError:
                    try:
                      i.readinto()
                    except AttributeError:
                      try:
                        i.__next__()
                      except AttributeError:
                        try:
                          i.flush()
                        except ValueError:
                          try:
                            i.__enter__()
                          except ValueError:
                            try:
                              i.isatty()
                            except ValueError:
                              x = 5
assert x == 5

i = _io._IOBase()
try:
  i.readlines()
except AttributeError:
  try:
    i.writelines(["5"])
  except AttributeError:
    x = 6
assert x == 6

