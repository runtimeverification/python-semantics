assert isinstance(5, (int, bool, float))
assert isinstance(5, (((int,), (bool, float)),))
assert not isinstance(5, ())
