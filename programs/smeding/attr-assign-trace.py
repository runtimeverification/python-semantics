# trace the order of evaluation of attribute assignments
# the rhs should be evaluated before the lhs!

class A(object) :
	pass

trace(1,A()).x = trace(0,None)

trace(2,None)
