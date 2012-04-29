assert 5 .__add__(6) == 6 .__add__(5) == int.__add__(5, 6) == 6 .__radd__(5) == 5 + 6 == 6 + 5 == 11
assert 6 .__sub__(5) == int.__sub__(6, 5) == 5 . __rsub__(6) == 6 - 5 == 1
assert 5 .__mul__(6) == 6 .__mul__(5) == int.__mul__(5, 6) == 6 .__rmul__(5) == 5 * 6 == 6 * 5 == 30
assert 5 .__truediv__(2) == int.__truediv__(5, 2) == 2 .__rtruediv__(5) == 5 / 2 == 2.5
assert 5 .__floordiv__(2) == int.__floordiv__(5, 2) == 2 .__rfloordiv__(5) == 5 // 2 == 2
assert 5 .__mod__(2) == int.__mod__(5, 2) == 2 .__rmod__(5) == 5 % 2 == 1
assert 5 .__pow__(2) == int.__pow__(5, 2) == 2 .__rpow__(5) == 5 ** 2 == 25
assert 5 .__pow__(-1) == int.__pow__(5, -1) == (-1).__rpow__(5) == 5 ** -1 == 0.2
assert 8 .__lshift__(2) == int.__lshift__(8, 2) == 2 .__rlshift__(8) == 8 << 2 == 32
assert 32 .__rshift__(2) == int.__rshift__(32, 2) == 2 .__rrshift__(32) == 32 >> 2 == 8
assert 5 .__and__(6) == 6 .__and__(5) == int.__and__(5, 6) == 6 .__rand__(5) == 5 & 6 == 6 & 5 == 4
assert 5 .__or__(6) == 6 .__or__(5) == int.__or__(5, 6) == 6 .__ror__(5) == 5 | 6 == 6 | 5 == 7
assert 5 .__xor__(6) == 6 .__xor__(5) == int.__xor__(5, 6) == 6 .__rxor__(5) == 5 ^ 6 == 6 ^ 5 == 3
