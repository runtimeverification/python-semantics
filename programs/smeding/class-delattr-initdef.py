# object attributes can be deleted as well

class A(object) :
    def __init__(self) :
        self.x = 1

a = A()
del a.x

expectException(AttributeError)
a.x
