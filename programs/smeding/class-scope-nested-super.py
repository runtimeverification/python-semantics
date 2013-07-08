# a nested class cannot refer to the outer class' members
# but the superclass expression can

class A(object) :
	x = object
	class B(x) :
		pass
