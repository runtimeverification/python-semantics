x = set()
x |= {"5"}
assert x == {"5"}
assert x < {"5", "6"}
assert x <= {"5", "6"}
assert x <= {"5"}
assert x != {"5", "6"}
assert not(x < set())
assert not(x < {"5"})
assert not(x <= set())
assert not(x != {"5"})
x |= {"6", "7"}
assert x == {"5", "6", "7"}
