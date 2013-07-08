# if next() raises the StopIteration exception, it should continue to do that
# on subsequent calls, even if the list is extended

list = [1]
it = list.__iter__()

next(it)

try :
	next(it)
except StopIteration as e :
	pass

list.append(2)

expectException(StopIteration)
next(it)
