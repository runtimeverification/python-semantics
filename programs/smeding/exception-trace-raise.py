# tests on the order of execution when raising, catch and finally clauses

class TestException(Exception) : 
	pass

try :
	try :
		try :
			raise trace(0, TestException())
		except trace(1, ValueError) as e:
				fail()
	except trace(2, TestException) as e :
		trace(3, None)
finally :
	trace(4, None)
