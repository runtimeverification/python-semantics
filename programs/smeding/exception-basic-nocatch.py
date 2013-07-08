setDescr("Caught an exception when it shouldn't be caught")

class TestException(Exception) : 
	pass
class OtherException(Exception) :
	pass

try :
	try :
		raise TestException()
	except OtherException as e:
		fail()
except TestException as e:
	pass
