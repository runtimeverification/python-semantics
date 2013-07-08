setDescr("caught exception is in scope in the exception body and after it")

try :
	raise Exception()
except Exception as e:
	e

try:
  e
  fail()
except NameError: pass
