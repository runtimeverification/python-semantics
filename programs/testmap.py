assert list(map(5 . __add__, [1, 2, 3, 4])) == [6, 7, 8, 9]
assert list(map(int .__add__, [1, 2, 3, 4], [4, 3, 2, 1])) == [5,5,5,5]
