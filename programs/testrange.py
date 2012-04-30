assert list(range(10)) == list(range(0,10)) == list(range(0,10,1)) == [0,1,2,3,4,5,6,7,8,9]
assert list(range(10,0)) == []
assert list(range(10,0,-2)) == [10,8,6,4,2]
