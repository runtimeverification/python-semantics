# the arguments of a subscription assigment are evaluated before __setitem__ is called

try :
	trace(1,None)[trace(2,None)] = trace(0,None)
except TypeError as e :
	trace(3,None)

trace(4,None)
