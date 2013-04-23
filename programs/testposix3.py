import posix

l = posix.listdir("programs/files")
assert "#" in l
assert "\u03c0" in l
assert "stat" in l
l2 = posix.listdir(b"programs/files")
assert b"#" in l2
assert b"\xcf\x80" in l2
assert b"stat" in l2
