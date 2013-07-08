# the finally clause is not executed when we yield from its body

def foo() :
    try :
        yield None
    finally :
        fail()

# this will print a warning because the finally block
# is executed when the generator is garbage collected
next(foo())
