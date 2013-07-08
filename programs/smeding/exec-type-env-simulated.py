# an object that simulates a dictionary by implementing the right methods 
# can not be used as the environment of an exec statement

class A(object) :
	def __getitem__(self, key) :
		return fail

expectException(TypeError)
exec("pass", A())
