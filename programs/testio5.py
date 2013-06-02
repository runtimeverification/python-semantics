import _io
i = _io.FileIO("programs/files/FileIO")
assert i.__enter__() is i
assert i.read() == b"abc\ndef\nghi\n" == _io.FileIO("programs/files/FileIO").readall()
assert i.__exit__() is None
assert i.closed
try:
  i.__enter__()
  assert False
except ValueError:
  pass
