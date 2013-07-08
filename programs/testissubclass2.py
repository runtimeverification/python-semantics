assert issubclass(bool, (int, float, dict))
assert issubclass(bool, (((int,), (float, dict)),))
assert not issubclass(bool, ())
