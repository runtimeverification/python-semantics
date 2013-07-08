# Try Except statements basic functionality

class TestException(Exception) : 
	pass

try :
	raise TestException()
	fail()
except TestException as e:
	pass
