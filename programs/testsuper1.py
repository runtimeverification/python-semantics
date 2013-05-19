s = super.__new__(super)
assert s.__self__ is None
assert s.__thisclass__ is None
assert s.__self_class__ is None

s = super(int, 5)
assert s.__self__ == 5
assert s.__thisclass__ is int
assert s.__self_class__ is int

s = super(int, True)
assert s.__self__ is True
assert s.__thisclass__ is int
assert s.__self_class__ is bool

s = super(int, bool)
assert s.__self__ is bool
assert s.__thisclass__ is int
assert s.__self_class__ is bool

s = super(int)
assert s.__self__ is None
assert s.__thisclass__ is int
assert s.__self_class__ is None

s = super(int, None)
assert s.__self__ is None
assert s.__thisclass__ is int
assert s.__self_class__ is None
