import builtins
builtins.__dict__["__debug__"] = False
try:
  assert False
  raise SystemError
except AssertionError: pass
