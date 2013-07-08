# raise statements can only raise expressions that are a subclass of BaseException
# catches can however catch any type

class A(object) :
    pass

expectException(TypeError)

try :
    raise A()
except A as a:
    fail()
