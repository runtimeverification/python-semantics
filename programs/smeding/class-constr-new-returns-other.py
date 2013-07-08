# run a trace for the construction of A whose __new__ returns an instance of B
# note especially that the init of B is executed rather than A's init
# and B.__init__ will only be called only once.

class A(object) :
    def __new__(self) :
        trace(0, None)
        return B()

    def __init__(self) :
        fail()

class B(object) :
    def __new__(self) :    
        trace(1, None)
        return object.__new__(self)

    def __init__(self) :
        trace(2,None)

A()
trace(3,None)
