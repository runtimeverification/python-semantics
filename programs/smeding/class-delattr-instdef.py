# Deleting an instance attribute

class A(object) :
    pass

a = A()
a.x = 1

del a.x

expectException(AttributeError)
a.x
