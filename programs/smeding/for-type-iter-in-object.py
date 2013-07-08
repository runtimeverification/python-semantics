# the __iter__ function for the list has to be in the class, not the object

class A(object) :
	pass

a = A()

def __iter__() :
	return [1].__iter__() # note that this is a perfectly valid iterator

a.__iter__ = __iter__


expectException(TypeError)

for i in a :
	pass
