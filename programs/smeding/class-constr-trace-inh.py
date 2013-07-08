# at construction of an object, the class' new and init functions are called
# the parent's init and new are not called (unless they are called explicitly)

class A(object) :
	def __new__(self) :
		fail()
		
	def __init__(self) :
		fail()

class B(A) :
	def __new__(self, x) :
		return trace(1,object.__new__(self))

	def __init__(self, x) :
		return trace(2,None)

B(trace(0,None))
trace(3,None) # to make sure the last trace has been run as well
