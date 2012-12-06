assert "5" == "5"
assert not ("5" == "6")
assert "5" .__add__("6") == str.__add__("5", "6") == "5" + "6" == "56"

try:
  "5" .__add__(6)
  assert False
except TypeError:
  x = 5
assert x == 5

assert "5" .__class__ is str
assert str .__class__ is type
assert str.__name__ == "str"
assert hash("hello world") == 4477797451044935522, hash("hello world")

assert "abc abc abc foo".rpartition("abc") == ("abc abc ", "abc", " foo")
assert "abc abc abc foo".rpartition("def") == ("", "", "abc abc abc foo")
try:
  "abc abc abc foo".rpartition(5)
  assert False
except TypeError:
  y = 6
assert y == 6
