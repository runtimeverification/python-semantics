assert "12345".startswith("1") is True
assert "12345".startswith("12") is True
assert "12345".startswith("23") is False
assert "12345".startswith("23", 1) is True
assert "12345".startswith("12",1) is False
assert "12345".startswith("34", 2, 4) is True
assert "12345".startswith("34", 2, 3) is False
assert "12345".startswith(("ab","12",5)) is True
assert "12345".startswith(("ab", "34")) is False
assert "12345".startswith("5", -1) is True
assert "12345".startswith("34", 2, -1) is True
assert "12345".startswith("34", 2, 100) is True

try:
  "12345".startswith((1,))
except TypeError:
  try:
    "12345".startswith("1", "2")
  except TypeError:
    try:
      "12345".startswith("1", 2, "3")
    except TypeError:
      x = 5
assert x == 5
