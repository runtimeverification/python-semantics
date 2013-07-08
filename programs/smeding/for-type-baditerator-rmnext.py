# see what happens to an iterator that removes its own next function

class A(object) :
	def __iter__(self) :
		return BadIterator()

class BadIterator(object) :
	def __iter__(self) :
		return self
	def __next__(self) :
		del BadIterator.__next__
		return 1

expectException(TypeError)
for i in A() :
	pass
