# the statements in the finally clause do not constitute a block

try :
	pass
finally :
	x = True

assertTrue(x)
