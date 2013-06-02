import _io
i = _io.FileIO("programs/files/FileIO") 
try:
  i.readinto(5)
  assert False
except TypeError: pass
assert i.readinto(bytearray(4)) == 4
