import posix
import errno

try:
  posix.stat("programs/files/filenotfound")
except FileNotFoundError as e:
  assert e.errno == errno.ENOENT
  try:
    posix.stat("programs/files/stat4/somefile")
  except PermissionError as e:
    assert e.errno == errno.EACCES
    try:
      posix.stat("programs/files/stat/somefile")
    except NotADirectoryError as e:
      assert e.errno == errno.ENOTDIR
      try:
        posix.stat("programs/files/" + "stat3/" * 100)
      except OSError as e:
        assert e.__class__ is OSError
        assert e.errno == errno.ELOOP
        try:
          posix.stat("programs/files/" * 1000)
        except OSError as e:
          assert e.__class__ is OSError
          assert e.errno == errno.ENAMETOOLONG
          x = 5

assert x == 5
