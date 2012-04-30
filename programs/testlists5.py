assert list((5,)) == [5]
assert list() == []
assert [True] == [1]
assert [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] == list([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
assert not [] == [1]
assert not [1] == []
assert not [5] == [6]
