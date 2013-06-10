a = {"foo": 5}
assert exec("assert globals()[\"foo\"] == 5", a) is None
assert exec("assert locals()[\"foo\"] == 5", a) is None
bar = 5
assert exec("assert globals()[\"bar\"] == 5") is None
assert exec("assert locals()[\"bar\"] == 5") is None
assert exec("assert globals()[\"bar\"] == 5", None, a) is None
assert exec("assert locals()[\"foo\"] == 5", None, a) is None
b = {"foo": 6}
assert exec("assert globals()[\"foo\"] == 5", a, b) is None
assert exec("assert locals()[\"foo\"] == 6", a, b) is None
c = {"__builtins__" : {"int": 5, "exec": exec, "globals": globals, "AssertionError": AssertionError}}
assert exec("assert int == 5", c) is None
assert exec("""def a():
  return int
assert a() == 5""", c) is None
assert exec("assert exec(\"assert int == 5\") is None", c) is None
assert exec("assert globals().get(\"int\") is None", c) is None

class A:
  def keys(self): return ()
  def __getitem__(self, val): raise KeyError

assert exec("assert locals().__class__ is A", None, A()) is None

def a():
  global x
  x = 5

assert exec(a.__code__) is None
assert x == 5
