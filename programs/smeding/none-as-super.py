# Check whether we can derive from none

expectException(TypeError)
class Foo(None) :
    pass
