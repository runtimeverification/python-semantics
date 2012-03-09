assert 5 is 5
assert not (5 is 6)

assert 5 .__add__(6) is 6 .__add__(5) is int.__add__(5, 6) is 6 .__radd__(5) is 5 + 6 is 6 + 5 is 11
assert 6 .__sub__(5) is int.__sub__(6, 5) is 5 . __rsub__(6) is 6 - 5 is 1
assert 5 .__mul__(6) is 6 .__mul__(5) is int.__mul__(5, 6) is 6 .__rmul__(5) is 5 * 6 is 6 * 5 is 30
assert 5 .__truediv__(2) is int.__truediv__(5, 2) is 2 .__rtruediv__(5) is 5 / 2 is 2.5
assert 5 .__floordiv__(2) is int.__floordiv__(5, 2) is 2 .__rfloordiv__(5) is 5 // 2 is 2
assert 5 .__mod__(2) is int.__mod__(5, 2) is 2 .__rmod__(5) is 5 % 2 is 1
assert 5 .__pow__(2) is int.__pow__(5, 2) is 2 .__rpow__(5) is 5 ** 2 is 25
assert 5 .__pow__(-1) is int.__pow__(5, -1) is (-1).__rpow__(5) is 5 ** -1 is 0.2
assert 8 .__lshift__(2) is int.__lshift__(8, 2) is 2 .__rlshift__(8) is 8 << 2 is 32
assert 32 .__rshift__(2) is int.__rshift__(32, 2) is 2 .__rrshift__(32) is 32 >> 2 is 8
assert 5 .__and__(6) is 6 .__and__(5) is int.__and__(5, 6) is 6 .__rand__(5) is 5 & 6 is 6 & 5 is 4
assert 5 .__or__(6) is 6 .__or__(5) is int.__or__(5, 6) is 6 .__ror__(5) is 5 | 6 is 6 | 5 is 7
assert 5 .__xor__(6) is 6 .__xor__(5) is int.__xor__(5, 6) is 6 .__rxor__(5) is 5 ^ 6 is 6 ^ 5 is 3

assert -(5) is int.__neg__(5) is 5 .__neg__() is -5
assert -(-5) is 5
assert +5 is int.__pos__(5) is 5 .__pos__() is 5
assert +-5 is -5
assert ~5 is int.__invert__(5) is 5 .__invert__() is -6

assert 5 < 6 < 7 < 8
assert 8 > 7 > 6 > 5
assert 5 <= 5 <= 6
assert 6 >= 6 >= 5
assert 5 == 5 == 5
assert 5 != 6 != 7

if 5: assert True
else: assert False
if 0: assert False
else: assert True

assert 5 .__add__("5") is NotImplemented
assert 5 .__bool__() is True
assert 0 .__bool__() is False
assert 5 .__class__ is int
assert int.__class__ is type
assert int.__name__ is "int"

try:
  5()
  assert False
except TypeError:
  x = 5
assert x == 5
