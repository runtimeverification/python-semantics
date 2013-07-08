# A function cannot delete a variable it inherited from the surrounding block

x = 1

def foo() :
    del x

expectException(UnboundLocalError)

foo()
