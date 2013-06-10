x = compile("assert False", "foo", "exec", 0, 0, 1)
assert exec(x) is None
x = compile("""
y = compile("assert False", "foo", "exec", 0, 0, -1)
assert exec(y) is None
""", "foo", "exec", 0, 0, 1)
assert exec(x) is None
x = compile("""
y = compile("assert False", "foo", "exec", 0, 0, 0)
try:
  exec(y)
  raise SystemError
except AssertionError: pass
""", "foo", "exec", 0, 0, 1)
assert exec(x) is None
