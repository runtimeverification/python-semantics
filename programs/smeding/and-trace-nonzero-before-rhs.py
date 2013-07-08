# check that the and operator is truly lazy, i.e., whether it calls nonzero on its lhs before evaluating the rhs

class A(object) :
	def __bool__(self) :
		trace(0,None)
		return True

assertTrue(1 == ( A() and trace(1,1) ))
trace(2,None)
