import _io
import sys

class A:
  def assertTrue(exp): assert exp
  def trace(count, exp):
    global x
    assert x == count
    x += 1
    return exp
  def fail(): assert False
  def expectException(e):
    global ex, hasex
    ex = e
    hasex = True
  def setDescr(s): pass

x = 0
hasex = False
class B(BaseException): pass
ex = B

sys.path = ["."]

content = _io.FileIO(sys.argv[1]).read()
codeobj = compile(content, sys.argv[1], 'exec', dont_inherit=True)
try:
  exec(codeobj, {key : A.__dict__[key] for key in A.__dict__ if not key.startswith("_")})
  assert not hasex
except ex:
  assert hasex
