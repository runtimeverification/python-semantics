class B: pass
b = B()

a, * b.x, c = (1, 2, 3, 4)
assert b.x == [2, 3]

b = [1, 2, 3, 4]
a, * b[2], c = (5, 6, 7, 8)
assert b == [1, 2, [6, 7], 4]
