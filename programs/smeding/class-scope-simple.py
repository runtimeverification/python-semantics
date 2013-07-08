setDescr("Could not refer to variable bound outside class definition")

a = True
class A(object) :
    x = a

assertTrue(A().x)

