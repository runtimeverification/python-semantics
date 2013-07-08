# if next raises anything other than a StopIteration
# the exception is passed on

class A(object) :
	def __iter__(self) :
		return MyIterator()

class MyIterator(object) :
	def __iter__(self) :
		return self

	def __next__(self) :
		raise MyException()

class MyException(Exception) :
	pass

expectException(MyException)
for i in A() :
	pass
