assert b"f" * 5 == b"fffff" == b"f" . __mul__(5) == b"f" . __rmul__(5)
assert bytes(5) == b"\0\0\0\0\0"
