setDescr("a class cannot derive from itself because it is not in scope")

try :
	class A(A) :
		fail()
except NameError as n :
	pass
