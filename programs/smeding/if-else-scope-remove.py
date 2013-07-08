setDescr("Variables can be removed in the block")

a = 1

if True :
	del a
else :
	pass

try :
	a
	fail()
except NameError as e :
	pass


a = 1

if False :
	pass
else :
	del a

try :
	a
	fail()
except NameError as e :
	pass
