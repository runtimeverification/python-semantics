setDescr("Variable defined before if, can be used in the if body")

a = True

if True :
	a
else :
	fail()

if False :
	fail()
else :
	a
