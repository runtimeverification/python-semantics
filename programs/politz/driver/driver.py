import _io
import sys

class A: 
  def assertEqual(self, other): assert self == other
  def fail(): assert False
  def assertFail(): assert False
  def assertFalse(self): assert not self
  def assertIn(self, other): assert self in other
  def assertIs(self, other): assert self is other
  def assertIsNot(self, other): assert self is not other
  def assertNotEqual(self, other): assert self != other
  def assertNotIn(self, other): assert self not in other
  def assertTrue(self): assert self
  def assertRaises(self, other, *args, **kwargs):
    try:
      other(*args, **kwargs)
    except self: return
    else: assert False
    assert False

sys.path = ["."]

content = _io.FileIO(sys.argv[1]).read()
codeobj = compile(content, sys.argv[1], 'exec', dont_inherit=True)
exec(codeobj, {"___" + key : A.__dict__[key] for key in A.__dict__ if not key.startswith("_")})
