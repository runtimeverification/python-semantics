# call with an incorrect number of arguments

setDescr("Function with no arguments called with an argument")

def foo() :
	return 1

expectException(TypeError)
foo(1)
