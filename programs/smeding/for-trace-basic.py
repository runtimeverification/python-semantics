# run a trace of the basic for loop

class L(object) :
	def __iter__(self) :
		i = I()
		return trace(0, I())

class I(object) :

	def __iter__(self) :
		fail()

	cnt = True

	def __next__(self) :
		if I.cnt :
			I.cnt = False
			return trace(1, "foo")
		else :
			trace(3, None)
			raise StopIteration()


for i in L() :
	trace(2, None)
