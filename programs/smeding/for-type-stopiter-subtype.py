# the for loop stops not just when next raises StopIteration, but also
# when it raises a child of StopIteration

class A(object) :
	def __iter__(self) :
		return MyIterator()

class MyIterator(object) :
	def __iter__(self) :
		return self

	def __next__(self) :
		raise MyStopIteration()
	
class MyStopIteration(StopIteration) :
	pass

for i in A() :
	pass
