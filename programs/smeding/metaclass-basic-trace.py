# check that both new and init of the metaclass are called.. in the correct order

class M(type) :
    def __new__(self, name, bases, attrs) :
        trace(1, None)
        return type.__new__(self, name, bases, attrs)

    def __init__(self, name, bases, attrs) :
        trace(2, None)

    def __call__(self) :
        fail()

class A(object, metaclass=M) :
    trace(0,None)

trace(3,None)
