assert {}.get(5) is None
assert {5: 6}.get(5) == 6
assert {}.get(5, 6) == 6
