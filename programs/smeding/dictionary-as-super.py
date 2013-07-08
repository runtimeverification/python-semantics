# the dictionary can be used as superclass, inheriting all its primitives

class A(dict) :
	pass

a = A()
a["spam"] = "meat"

assertTrue(a["spam"] == "meat")
