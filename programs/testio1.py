import _io
i = _io._IOBase()
assert i.__iter__() is i
assert not i.closed
assert i.close() is None
assert i.closed
i = _io._IOBase()
assert i.__enter__() is i
assert i.__exit__(1, 2, 3, 4, 5, 6, 7) is None
assert i.closed
i = _io._IOBase()
assert i.flush() is None
assert i.readline(0) == b""
assert not i.isatty()
assert not i.readable()
assert not i.seekable()
assert not i.writable()
assert i.writelines([]) is None
