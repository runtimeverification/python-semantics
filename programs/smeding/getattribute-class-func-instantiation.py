# overloading object.__getattribute__ to disable instantiation of foo

class A(object) :
	def __getattribute__(self, attr) :
		if attr in A.__dict__ :
			return A.__dict__[attr]
		else :
			return object.__getattribute__(self, attr)

	def foo(x) :
		return x

assertTrue(A().foo(1) == 1)
