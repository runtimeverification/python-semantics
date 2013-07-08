# check how raising the StopIteration exception in the body stops execution
# it should just stop with the raised StopIteration exception, not as if
# the end of the list has been reached

expectException(StopIteration)

for i in [1] :
	raise StopIteration()

fail()
