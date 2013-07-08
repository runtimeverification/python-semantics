# when a generator's next is called while it is already running 
# an exception should be thrown

def gen() :
	trace(0,0) # call itself in trace to prevent a loop
	next(it)
	yield 1

it = gen()
expectException(ValueError)
next(it)
