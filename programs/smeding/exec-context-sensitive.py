# the parser of the exec statement is not context sensitive
# it won't allow returns in functions that are not part of the string

def foo() :
    exec("return 1", {})

expectException(SyntaxError)
foo()
