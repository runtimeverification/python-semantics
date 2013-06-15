import package1.module2
from package1.module2 import *

assert package1.module2.x == 5
assert package1.module2.y == 5
assert x == 5
try:
  y
  assert False
except NameError: pass
