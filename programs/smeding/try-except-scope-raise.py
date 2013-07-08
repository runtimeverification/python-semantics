# variable defined in try with raise is accessible in the exception and after try

try :
	a = True
	raise Exception()
except Exception as e :
	assertTrue(a)

assertTrue(a)
