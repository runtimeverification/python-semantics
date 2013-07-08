# see if a subtype of string can be used in exec

class A(str) :
	pass

exec(A("foo(0, None)"), {"foo" : trace})
