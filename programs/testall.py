assert all(()) is True
assert all((1,)) is True
assert all((0,)) is False
assert all((1,2,3,4)) is True
assert all((1,2,3,4,0)) is False
