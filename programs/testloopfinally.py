x = 5
try:
  while x > 0:
    try:
      raise
    finally:
      y = 6
      assert x == 5
    assert False
  assert False
except RuntimeError:
  z = 7
  assert y == 6
assert z == 7

x = 6
while x > 0:
  try:
    break
    assert False
  finally:
    y = 7
    assert x == 6
  assert False
assert y == 7

x = 3
y = 1
while x > 0:
  x = x - 1
  try:
    continue
    assert False
  finally:
    y = y + 1
  assert False
assert y == 4

x = 8
while x > 0:
  try:
    x = x - 1
  finally:
    break
    assert False
  assert False
else:
  assert False
assert x == 7

try:
  for x in (1, 2, 3):
    try:
      raise
    finally:
      y = 5
      assert x == 1
    assert False
  assert False
except RuntimeError:
  z = 6
  assert y == 5
assert z == 6

for x in (2, 3, 4):
  try:
    break
    assert False
  finally:
    y = 6
    assert x == 2
  assert False
assert y == 6

y = 2
for x in (3, 4, 5):
  try:
    continue
    assert False
  finally:
    y = y + 1
  assert False
assert y == 5

for x in (4, 5, 6):
  try:
    y = x - 1
  finally:
    break 
    assert False
  assert False
else:
  assert False
assert y == 3
