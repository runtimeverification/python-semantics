# check that renaming a class in the metatype's constructor does not change the binding

class M(type) :
	def __new__(self, name, bases, dict) :
		return type.__new__(self, "B", bases, dict)

class A(object, metaclass=M) :
	x = True

assertTrue(A.x)
