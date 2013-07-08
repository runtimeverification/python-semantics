# bool cannot be a supertype

expectException(TypeError)
class Spam(bool) :
    pass
