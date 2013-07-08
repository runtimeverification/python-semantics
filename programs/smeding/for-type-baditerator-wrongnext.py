# check what happens if the iterator's next has the wrong type

class A(object) :
	def __iter__(self) :
		return BadIterator()

class BadIterator(object) :
	def __iter__(self) :
		return self

	next = 1

expectException(TypeError)

for i in A() :
	pass
