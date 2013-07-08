# try to access a locally defined class variable in a function

setDescr("Class function scope should not include other class attributes")

class A(object) :
    a = 3
    def f(self) :
        return a # a shouldn't be in scope!

try :
    A().f()
    fail()
except NameError as n :
    pass
