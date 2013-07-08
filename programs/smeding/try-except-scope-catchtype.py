# variable defined in try is even accessible in except clause

setDescr("Catching an exception defined in the try body")

try :
	a = Exception
	raise Exception()
except a as e:
	pass
