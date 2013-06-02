import _io
i = _io.FileIO("programs/files/FileIO")
_io._IOBase.close(i)
assert _io._IOBase.closed.__get__(i, _io._IOBase)
assert not i.closed
i.close()
assert i.closed
