# Uncaught exception binding is still in scope

try :
	try :
		raise Exception()
	except None as n :
		pass
except Exception as e :
	expectException(NameError)
	n
