# arguments of a function call with an incorrect number of arguments
# should be evualated before the TypeError is raised

# create a class to pass a boolean by reference
class Reference(object) :
	pass

def bar(ref) :
	ref.value = True

setDescr("Argument of a function call with too few arguments, was not evaluated")

# with too few arguments
try :
	def foo(a, b) :
		pass

	a = Reference()
	a.value = False
	foo(bar(a))
	fail() # Function call with too few arguments was executed
except TypeError as e :
	if a.value :
		pass
	else :
		fail()

