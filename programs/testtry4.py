try:
  raise Exception
except Exception as e:
  assert e.__class__ == Exception
