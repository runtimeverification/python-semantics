# tests on the order of execution in case no exceptions are raised

class TestException(Exception) : 
	pass

try :
	try :
		trace(0, None)
	except fail() as e:
		fail()
finally :
	trace(1, None)
