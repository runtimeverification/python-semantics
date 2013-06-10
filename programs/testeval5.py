a = {"__builtins__": {}}
assert eval("True", a) is True
assert eval("False", a) is False
assert eval("None", a) is None
