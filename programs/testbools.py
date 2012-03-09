assert False is (not True)
assert True is (not False)
assert (True and True) is True
assert (True and False) is False
assert (False and 5 / 0) is False
assert (True or False) is True
assert (False or False) is False
assert (True or 5 / 0) is True
assert True .__class__ is False .__class__ is bool
assert bool.__class__ is type, bool.__class__
assert bool.__class__ == type
assert bool.__name__ is "bool"
assert not None
assert (5,)
assert not ()
assert (5 and 6) is 6
assert (0 and 6) is 0
assert (5 or 6) is 5
assert (0 or 6) is 6
assert bool(0) is False
assert bool(1) is True
assert bool() is False
