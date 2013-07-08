# raising any exception in a generator will stop the generator 

class E(Exception) :
	pass

def foo() :
	raise E()
	yield 1

f = foo()

try :
	next(f)
except E as e:
	pass

expectException(StopIteration)
next(f)
