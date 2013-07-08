setDescr("An instantiated class member cannot be instantiated again")

class A(object) :
	def f(a,b) :
		return b

class B(object) :
	f = A().f

assertTrue(B().f(1) == 1)
