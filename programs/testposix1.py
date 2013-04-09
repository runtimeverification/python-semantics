import posix

mask = 0o170000
S_IFDIR = 0o40000
S_IFREG = 0o100000

sr = posix.stat("programs/stat")
assert sr.st_mode & mask == S_IFREG

sr2 = posix.stat("programs/stat2")
assert sr2.st_mode & mask == S_IFDIR
