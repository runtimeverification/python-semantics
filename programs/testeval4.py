try:
  eval("5;6")
  assert False
except SyntaxError: pass
