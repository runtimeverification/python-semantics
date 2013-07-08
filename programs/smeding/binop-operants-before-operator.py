# the operants are evaluated before the operator

class A(object) :
    pass

try :
    trace(0,A()) + trace(1,A())
except TypeError as e:
    trace(2,None)

trace(3,None)
