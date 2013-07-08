# attributes can be deleted as they are considered locals

def foo(x) :
	del x

foo(None)


# we would expect a local unbound when the variable is used after deletion

def foo(x) :
	del x
	x

expectException(UnboundLocalError)
foo(None)
