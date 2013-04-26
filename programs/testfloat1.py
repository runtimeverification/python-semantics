assert int(5.99) == 5
assert 5.99 < 6 <= 6.0
assert 5.0 <= 5 < 5.01
assert 6.0 >= 6 > 5.99
assert 5.01 > 5 >= 5.0
assert 6.0 >= 6.0 >= 5.99
assert 5.99 <= 6.0 <= 6.0
assert 5 == 5.0 != 5.01
assert 5 != 5.01 == 5.01
