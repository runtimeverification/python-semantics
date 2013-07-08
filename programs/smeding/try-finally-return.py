# the finally clause is also executed when we return from its body

def foo() :
    try :
        return trace(0,None)
    finally :
        trace(1, None)

foo()
trace(2,None)
