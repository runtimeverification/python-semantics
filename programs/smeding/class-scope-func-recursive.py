# A class method cannot call itself recursively

class A(object) :
	def f(self, x) :
		if x :
			return f(self, False)
		else :
			return None

expectException(NameError)

A().f(True)
