assert "12345".startswith("1")
assert "12345".startswith("12")
assert not "12345".startswith("23")
assert "12345".startswith("23", 1)
assert not "12345".startswith("12",1)
assert "12345".startswith("34", 2, 4)
assert not "12345".startswith("34", 2, 3)
assert "12345".startswith(("ab","12",5))
assert not "12345".startswith(("ab", "34"))
assert "12345".startswith("5", -1)
assert "12345".startswith("34", 2, -1)
assert "12345".startswith("34", 2, 100)

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
