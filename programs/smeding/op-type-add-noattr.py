# check wether a TypeError is raised if + is used for an object without
# the __add__ attribute

class A(object) :
	pass

expectException(TypeError)
A() + 1
