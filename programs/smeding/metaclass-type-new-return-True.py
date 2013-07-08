
class M(type) :
	def __init__(self, name, bases, dict) :
		fail()

	def __new__(self, name, bases, dict) :
		trace(0, None)
		return N(name, bases, dict)


class N(type) :
	def __init__(self, name, bases, dict) :
		trace(1, None)


class A(object, metaclass=M) :
	pass


trace(2, None)
