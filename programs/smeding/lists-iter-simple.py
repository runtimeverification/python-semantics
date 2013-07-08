# check basic behaviour of a lists' iterator

it = [1,2].__iter__()

assertTrue(next(it) == 1)
assertTrue(next(it) == 2)

expectException(StopIteration)
next(it)
