# calling static class functions

setDescr("Class functions are not instantiated")

class A(object) :
	def foo(self) :
		return 1

assertTrue(A.foo(A()) == 1)

expectException(TypeError)

A.foo()
