x = ((a, b, c) for a in range(4) for b in range(4) if b < 2 for c in range(4) if 1 < c if c < 3)

assert list(x) == [(0, 0, 2), (0, 1, 2), (1, 0, 2), (1, 1, 2), (2, 0, 2), (2, 1, 2), (3, 0, 2), (3, 1, 2)] == [(a, b, c) for a in range(4) for b in range(4) if b < 2 for c in range(4) if 1 < c if c < 3]
assert {(0, 0, 2), (0, 1, 2), (1, 0, 2), (1, 1, 2), (2, 0, 2), (2, 1, 2), (3, 0, 2), (3, 1, 2)} == {(a, b, c) for a in range(4) for b in range(4) if b < 2 for c in range(4) if 1 < c if c < 3}
assert {0: 1, 1: 2} == {x : x + 1 for x in range(2)}
