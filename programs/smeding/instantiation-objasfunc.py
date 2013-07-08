# object-functions i.e., objects with the __call__ attribute pointing to a 
# function are always instantiated with the object that contains the function

class A(object) :
	test = True

	def __call__(self) :
		return self.test

class B(object) :
	test = False

	foo = A() # this creates an instance of A, it doesn't call A.__call__ !

assertTrue(B().foo())
