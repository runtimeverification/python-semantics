# Object members that are functions are not instantiated, unlike class functions

class A(object) :
	pass

def foo(a) :
	return a

a = A()

a.bar = foo

assertTrue(a.bar(1) == 1)
