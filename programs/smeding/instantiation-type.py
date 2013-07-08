setDescr("a function's class cannot be changed once it has been set")

class A(object) :
	def foo(self) :
		return 1

class B(object) :
	foo = A.foo

b = B()
b.foo()
assertTrue(b.foo() == 1)
