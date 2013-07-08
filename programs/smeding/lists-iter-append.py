# check what happens if a list is extended after the iterator has been created

list = [1]
it = list.__iter__()

assertTrue(next(it) == 1)

list.append(2)

assertTrue(next(it) == 2)
