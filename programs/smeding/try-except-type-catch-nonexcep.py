# only subtypes of BaseException can catch an exception

expectException(Exception)

try :
	raise Exception()
except object as e : # Exception is an instance of object
	fail()
