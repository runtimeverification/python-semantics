assert "5" is "5"
assert "5" == "5"
assert not ("5" is "6")
assert "5" .__add__("6") is str.__add__("5", "6") is "6" .__radd__("5") is "5" + "6" is "56"
assert "5" .__add__(6) is NotImplemented
assert "5" .__class__ is str
assert str .__class__ is type
assert str.__name__ is "str"
assert hash("hello world") == -2324238377118044897, hash("hello world")
