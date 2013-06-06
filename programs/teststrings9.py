assert "foo abc abc abc".partition("abc") == ("foo ", "abc", " abc abc")
assert "foo abc abc abc".partition("def") == ("foo abc abc abc", "", "")
try:
  "abc abc abc foo".partition(5)
  assert False
except TypeError: pass
