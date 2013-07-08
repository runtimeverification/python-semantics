setDescr("Function with lambda is not instantiated")

class A(object) :
	f = lambda self: True

assertTrue(A().f())
