# check inheritance of setattr: only the class attribute __setattr__ should
# be called, the object's own setattr is off limits

class A(object) :
	def __setattr__(self, attr, val) :
		trace(0, None)

def __setattr__(self, attr, val) :
	pass

a = A()
object.__setattr__(a, "__setattr__", __setattr__)

a.x = 1 # should increace the trace by one through A.__setattr__
trace(1, None)
