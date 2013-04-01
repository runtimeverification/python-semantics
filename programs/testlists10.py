x = [1, 2, 3]
x.append(4)
assert x == [1, 2, 3, 4]
x.append([])
assert x == [1, 2, 3, 4, []]
