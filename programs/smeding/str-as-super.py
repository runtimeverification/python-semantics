# using str as super type

class A(str) :
	pass

assertTrue(A("spam") == "spam")
assertTrue(A() == "")
