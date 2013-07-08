# variables defined inside a class can use eachother
# and they shadow earlier defined variables

setDescr("Faulty variable binding in class definition")

a = 0
class A(object) :
    a = 1
    b = a # should refer to the last a

assertTrue(A().a == 1)
assertTrue(A().b == 1)
