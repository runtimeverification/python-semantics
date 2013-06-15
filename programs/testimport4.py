try:
  from . import foo
  assert False
except SystemError: pass
