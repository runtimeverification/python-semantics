# if next() raises the StopIteration exception, it should continue to do that
# on subsequent calls

it = [1].__iter__()

next(it)

try :
	next(it)
except StopIteration as e :
	pass

expectException(StopIteration)
next(it)
