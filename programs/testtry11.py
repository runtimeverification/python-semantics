try:
  try:
    raise
    assert False
  except RuntimeError:
    raise SyntaxError
  assert False
except SyntaxError as e:
  assert e.__context__.__class__ == RuntimeError
