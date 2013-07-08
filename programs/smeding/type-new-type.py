# type's constructor new can only be called for types, not objects

class A(object) :
	def __new__(self) :
		return type.__new__(self) # should've called object.__new__

expectException(TypeError)
A()
