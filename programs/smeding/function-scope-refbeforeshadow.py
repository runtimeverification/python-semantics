# a variable cannot be referenced before it is defined
# even if the variable was inherited as well

x = 1

def foo() :
    trace(1, x)
    fail()
    x = 1

expectException(UnboundLocalError)

trace(0,foo())
