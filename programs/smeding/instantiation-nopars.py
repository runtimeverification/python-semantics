# class functions without parameters (and therefore no self) can be created, 
# but not called as attributes

setDescr("Calling a non-instantiatable function should throw an exception")

class A(object) :
	def f() : 
		return None

try :
	A().f()
except TypeError as e:
	pass
