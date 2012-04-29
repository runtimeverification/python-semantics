try:
  try:
    e
    assert False
  except NameError as e:
    x = 8
    raise
    assert False
except NameError as f:
  try:
    e
    assert False
  except NameError:
    y = 9
assert x == 8 and y == 9
