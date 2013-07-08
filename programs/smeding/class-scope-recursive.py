# Classes cannot refer to themselves in their function body

expectException(NameError)

class A(object) :
	a = A()
