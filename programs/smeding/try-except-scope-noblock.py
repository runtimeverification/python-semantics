# variables defined in try still accessible after try statement

setDescr("Variable defined in try body before raise is not in scope")

try :
	a = True
except Exception as e :
	pass

assertTrue(a)
