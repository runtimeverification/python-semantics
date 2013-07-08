setDescr("Variables can be redefined in the function body, not shadowed")

a = 1

if True :
	a = 2
else :
	pass

assertTrue(a == 2)

if False :
	pass
else :
	a = 3
	
assertTrue(a == 3)
