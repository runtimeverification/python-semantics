import _io
module = type(_io)
m = module.__new__(module)
assert m.__dict__ is None
try:
  m.__init__()
except TypeError:
  m.__init__("foo")
  assert m.__dict__.__class__ is dict
  assert m.__name__ == "foo"
