assert eval(compile("5", "foo", "eval")) == 5
assert eval(compile("5", "foo", "exec")) is None
