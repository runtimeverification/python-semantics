def f():
  try: 
    raise
  finally:
    return 5
assert f() == 5
