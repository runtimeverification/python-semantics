# a function can not delete the reference to itself

def foo() :
	del foo

expectException(UnboundLocalError)
foo()
