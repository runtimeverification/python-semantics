# instantiation doesn't care about the attribute name
# using 'self' is only a convention

setDescr("Selfs seems to be implicitly instantiated")

self = True

class A(object) :
	def f(a) :
		return self
	def g(a,self) :
		return self

assertTrue(A().f())
assertTrue(A().g(1) == 1)
