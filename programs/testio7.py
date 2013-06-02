import _io
import errno
i = _io.FileIO("programs/files/FileIO")
i2 = _io.FileIO(i.fileno())
i.close()
try:
  i2.close()
  assert False
except OSError as e:
  assert e.errno == errno.EBADF
