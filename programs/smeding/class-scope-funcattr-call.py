# class variables can use class functions to be initialized

setDescr("Could not initialize class attribute using class function")

class A(object) :
    def f() :
        return 1

    a = f()
