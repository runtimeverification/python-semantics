setDescr("If uses the nonzero function of an object's class")

class A(object) :
	def __bool__(self) :
		return False

def nonzero(self) :
	return True

a = A()
a.__nonzero__ = nonzero

if a :
	fail()
else :
	pass
