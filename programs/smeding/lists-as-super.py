# check if lists can be used as base types

class A(list) :
	pass

a = A()
a.append(1)

assertTrue(a[0] == 1)
