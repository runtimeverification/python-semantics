# a variable that is defined in the try block, but before rising the exception
# will still be in scope in the finally clause

try :
	try :
		a = True
		raise Exception()
	except Exception as e:
		b = True
		pass
finally :
	assertTrue(a)
	assertTrue(b)
