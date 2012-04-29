assert -(5) == int.__neg__(5) == 5 .__neg__() == -5
assert -(-5) == 5
assert +5 == int.__pos__(5) == 5 .__pos__() == 5
assert +-5 == -5
assert ~5 == int.__invert__(5) == 5 .__invert__() == -6
