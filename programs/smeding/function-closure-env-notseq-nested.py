# this is a slightly more complicated version of
# function-closure-env-notseq.py

x = 1

def foo() :
    def bar() :
        return x
    x = 2
    return bar

assertTrue(foo()() == 2)
