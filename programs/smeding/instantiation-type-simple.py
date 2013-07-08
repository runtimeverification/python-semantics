# class functions can only be instantiated with an instance of the class

class A(object) :
	def foo(self) :
		return 1

assertTrue(A.foo(1) == 1)
