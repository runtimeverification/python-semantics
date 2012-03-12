a, b, c, d, e = 1, 2, 3, 4, 5

del a, b

try:
  a
  assert False
except NameError:
  pass

try:
  b
  assert False
except NameError:
  pass

del (c, [d, (e,)])

try:
  c
  assert False
except NameError:
  pass

try:
  d
  assert False
except NameError:
  pass

try:
  e
  assert False
except NameError:
  pass
