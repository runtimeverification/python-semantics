assert 5 .__add__("5") is NotImplemented
assert 5 .__bool__() is True
assert 0 .__bool__() is False
assert 5 .__class__ is int
assert int.__class__ is type
assert int.__name__ == "int"
