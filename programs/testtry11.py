try:
  try:
    raise
    assert False
  except RuntimeError:
    raise SyntaxError
  assert False
except SyntaxError as e:
  assert e.__context__.__class__ == RuntimeError
  assert e.__cause__ is None
  assert not e.__suppress_context__
  assert e.__traceback__.tb_next is None
