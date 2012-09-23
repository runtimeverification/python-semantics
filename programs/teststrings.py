assert "5" is "5"
assert "5" == "5"
assert not ("5" is "6")
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
assert hash("hello world") == -2324238377118044897, hash("hello world")
