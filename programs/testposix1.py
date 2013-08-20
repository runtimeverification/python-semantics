import posix

mask = 0o170000
mask2 = 0o777
S_IFDIR = 0o40000
S_IFREG = 0o100000
S_IFLNK = 0o120000

sr = posix.stat("programs/files/stat")
assert sr.st_mode & mask == S_IFREG
assert sr.st_mode & mask2 == 0o664
assert sr.st_dev == 0x815
assert sr.st_ino.__class__ is int
assert sr.st_nlink.__class__ is int
assert sr.st_uid == 1003
assert sr.st_gid == 1003
assert sr.st_size == 4
assert int(sr.st_atime) >= 1372977779, sr.st_atime
assert int(sr.st_mtime) >= 1366755120, sr.st_mtime
assert sr.st_ctime.__class__ is float

sr2 = posix.stat("programs/files/stat2")
assert sr2.st_mode & mask == S_IFDIR

sr3 = posix.stat("programs/files/stat3", follow_symlinks=False)
assert sr3.st_mode & mask == S_IFLNK
sr3 = posix.stat("programs/files/stat3")
assert sr3.st_mode & mask == S_IFDIR
