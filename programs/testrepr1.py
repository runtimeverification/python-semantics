assert repr("\x00\x1f\x7f") == "'\\x00\\x1f\\x7f'", repr("\x00\x1f\x7f")
assert repr("foo") == "'foo'"
assert repr("foo ' bar") == "\"foo ' bar\""
assert repr("foo \" bar") == "'foo \" bar'"
assert repr("foo ' \" bar") == "'foo \\' \" bar'"
assert repr("foo\\bar") == "'foo\\\\bar'"
assert repr("foo\nbar") == "'foo\\nbar'"
assert repr("foo\tbar") == "'foo\\tbar'"
assert repr("foo\rbar") == "'foo\\rbar'"
