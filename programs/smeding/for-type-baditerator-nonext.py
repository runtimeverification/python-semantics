# check what happens if the iterator returned for the list has no next func

class A(object) :
	def __iter__(self) :
		return BadIterator()

class BadIterator(object) :
	def __iter__(self) :
		return self

expectException(TypeError)
for i in A() :
	pass
