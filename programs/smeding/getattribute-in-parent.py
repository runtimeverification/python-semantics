# one can inherit from a class that has custom attribute retrieval
# but the child will use the inherited __getattribute__

class A(object) :
	def __getattribute__(self, attr) :
		return 1

class B(A) :
	x = 2

assertTrue(B().y == 1)
assertTrue(B().x == 1)

b = B()
b.z = 2

assertTrue(b.z == 1)
