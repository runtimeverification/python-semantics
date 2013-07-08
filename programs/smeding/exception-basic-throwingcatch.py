# raising an exception in the except clause will override the original exception

class TestException(Exception) :
	pass

def raiseException() :
	raise TestException()
	return TestException

try :
	try :
		raise TestException()
	except raiseException() as e: # evaluating the function will throw an exception
		fail() # therefore, the body of the except cluase should not be entered
except TestException as e:
	pass
