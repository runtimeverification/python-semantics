# calling __str__ on a subclass of str will return the 'inner' string
# or a copy, not the object itself

class A(str) :
    pass

a = A()
a.x = 1

expectException(AttributeError)
a.__str__().x
