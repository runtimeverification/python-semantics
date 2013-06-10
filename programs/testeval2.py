a = {}
assert eval("globals()", a) is a
assert eval("locals()", a) is a
assert eval("globals()") is globals()
assert eval("locals()") is locals()
assert eval("globals()", None, a) is globals()
assert eval("locals()", None, a) is a
b = {}
assert eval("globals()", a, b) is a
assert eval("locals()", a, b) is b
c = {"__builtins__" : {"int": 5, "eval": eval, "globals": globals}}
assert eval("int", c) == 5
assert eval("(lambda: int)()", c) == 5
assert eval("eval(\"int\")", c) == 5
assert eval("globals().get(\"int\")", c) is None

class A:
  def keys(self): return ()
  def __getitem__(self, val): raise KeyError

assert eval("locals()", None, A()).__class__ is A

def a(): return 5

assert eval(a.__code__) == 5

