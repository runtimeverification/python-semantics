# a class function is not type/class specific when it is retrieved from the
# class object's dictionary

class A(object) :
	def foo(x) :
		return x

assertTrue(A.__dict__["foo"](1) == 1)
