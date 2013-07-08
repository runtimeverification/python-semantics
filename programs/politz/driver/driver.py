import _io
import sys

class A: 
  def assertEqual(self, other): assert self == other, (self, other)
  def fail(msg=""): assert False, msg
  def assertFail(msg=""): assert False, msg
  def assertFalse(self): assert not self, self
  def assertIn(self, other): assert self in other, (self, other)
  def assertIs(self, other): assert self is other, (self, other)
  def assertIsNot(self, other): assert self is not other, (self, other)
  def assertNotEqual(self, other): assert self != other, (self, other)
  def assertNotIn(self, other): assert self not in other, (self, other)
  def assertTrue(self): assert self, self
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
