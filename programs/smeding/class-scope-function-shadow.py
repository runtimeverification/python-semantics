# variables in class functions never refer to a class variable

setDescr("Variables in class function can not be shadowed by class attributes")

a = 0

class A(object) :
    a = 1
    def f(self) :
        return a # returns 0, not 1

assertTrue(A().f() == 0)
