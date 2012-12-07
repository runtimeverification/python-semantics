assert b"foo" > b"fo" >= b"f"
assert not b"foo" > b"foo"
assert b"foo" >= b"foo"
assert b"f" <= b"fo" < b"foo"
assert not b"foo" < b"foo"
assert b"foo" <= b"foo"
assert b"foo" == b"foo" != b"fo"

assert b"fo" + b"o" == b"foo", b"fo" + b"o"
