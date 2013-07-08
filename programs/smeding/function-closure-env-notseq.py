# The environment in the body of a function that is inherited from the 
# surrounding block, is not a copy, but a reference. As a consequence one can
# use variables defined after the function definition, but before the call

def foo() :
	return x

x = 1

assertTrue(foo() == 1)
