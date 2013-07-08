# the arguments of a subscription are evaluated before accessing |__getattribute__|

try :
	trace(0,None)[trace(1,None)]
except TypeError as e:
	trace(2,None)

trace(3,None)
