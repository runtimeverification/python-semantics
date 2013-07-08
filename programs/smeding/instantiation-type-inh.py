# A class function can be instantiated with a subclass

class A(object) :
	def foo(self) :
		return 1

class B(A) :
	bar = A.foo

B().bar()
