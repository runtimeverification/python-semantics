# using a metaclass to override getattribute of a type shows that
# type.__getattribute__ performs the type check for class functions

class Meta(type) :
    def __getattribute__(self, attr) :
        return True

class A(object, metaclass=Meta) :
    x = False

assertTrue(A.x)
