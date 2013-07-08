# override the binding and call it even if it's not a function
# to make sure it doesn't infer which binding to use

setDescr("Function name was not shadowed in the function body when called as function.")

def foo(foo, i) :
	if 0 < i :
		foo(foo, i-1)
	else :
		pass

expectException(TypeError)

foo(1,1)
