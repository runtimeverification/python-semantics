setDescr("A nested class' body cannot refer to the outer class' attributes")

try :
    class A(object) :
        x = 1
        class B(object) :
            y = x
    fail()
except NameError as n :
	pass
