# check if an exec statement can introduce new local variables
# and whether it shadows variables in the outside scope

x = True

def foo() :
	assertTrue(x)
	exec("x = False")

foo()
assertTrue(x)
