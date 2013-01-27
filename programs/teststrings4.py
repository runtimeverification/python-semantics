assert "abc abc abc foo".rpartition("abc") == ("abc abc ", "abc", " foo")
assert "abc abc abc foo".rpartition("def") == ("", "", "abc abc abc foo")
try:
  "abc abc abc foo".rpartition(5)
  assert False
except TypeError:
  y = 6
assert y == 6
