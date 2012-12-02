def f():
  try: 
    1/0
  finally:
    return 5
assert f() == 5
