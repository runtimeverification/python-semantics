# an except clause only catches exceptions that are (sub)types of the catch
# classes sharing a common base will not catch oneanother

class A(Exception) : 
	pass
class B(A) : 
	pass

try :
	try :
		raise A()
	except B as e :
		fail()
except A as e :
	pass
