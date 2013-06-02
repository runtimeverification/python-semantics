import _io
i = _io.FileIO.__new__(_io.FileIO)
assert i.closed
try:
  i.readable()
  assert False
except ValueError:
  try:
    i.writable()
    assert False
  except ValueError:
    try:
      i.seekable()
      assert False
    except ValueError:
      try:
        i.fileno()
        assert False
      except ValueError: pass
assert i.closefd
i.__init__("programs/files/FileIO")
assert i.readable()
assert not i.writable()
assert i.closefd
assert i.fileno().__class__ is int
i.close()
