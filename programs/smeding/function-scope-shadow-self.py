# override the binding for foo inside the function, thus preventing looping

setDescr("Function name was not shadowed in the function body.")

def foo(foo) :
	return foo

assertTrue(1 == foo(1))
