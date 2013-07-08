# check if a valid iterator is returned for an empty list

it = [].__iter__()

expectException(StopIteration)
next(it)
