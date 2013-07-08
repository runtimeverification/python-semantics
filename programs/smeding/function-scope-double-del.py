# when a variable is deleted twice it should produce an unbound local error, 
# even if it used to be bound

def foo() :
	x = 1
	del x
	del x

expectException(UnboundLocalError)

foo()
