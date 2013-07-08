# see if we can remove the __nonzero__ function of the while's test
# while the loop is running

class A(object) :
	def __bool__(self) :
		return trace(2,False)

class B(A) :
	def __bool__(self) :
		del B.__bool__
		return trace(0,True)

b = B()

while b :
	trace(1,None) # this trace ensures we don't loop endlessly
