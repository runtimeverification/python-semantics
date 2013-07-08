# see if lambda's have the same scope restrictions as functions have

x = True

class A(object) :
    x = False
    foo = lambda self : x

assertTrue(A().foo())
