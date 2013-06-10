assert exec("""try:
  assert False
  raise SystemError
except AssertionError: pass""") is None
try:
  exec("assert False")
  raise SystemError
except AssertionError: pass

try:
  exec('exec("assert False")')
  raise SystemError
except AssertionError: pass

try:
  exec("return 5")
  assert False
except SyntaxError: pass
