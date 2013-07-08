# exceptions that have been caught are available in the finally clause

try :
	try :
		raise Exception()
	except Exception as e :
		pass
finally :
    try:
      e
      fail()
    except NameError: pass
