# a callable object will be instantiated only once

class B(object) :
    def __call__(self,x) :
        return x

class A(object) :
    __call__ = B() # B() won't be instantiated with an A object

assertTrue(A()(True))
