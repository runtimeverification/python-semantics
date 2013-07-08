# object's new function can only produce objects descendents of object

# this is more illustrating than a direct call to object.__new__
class A(int) :
	def __new__(self) :
		return object.__new__(self) # we should call int.__new__

expectException(TypeError)
A()
