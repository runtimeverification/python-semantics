setDescr("Removing the class' attribute should not be allowed")

class A(object) :
    a = 1

try :
    del A().a
    fail()
except AttributeError as e :
    pass
