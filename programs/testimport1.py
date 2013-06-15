import module1
import module1 as foo
from module1 import x

assert module1.x == 5
assert foo.x == 5
assert x == 5

try:
  from module1 import y
  assert False
except ImportError: pass
