class Meta(type) :
    t = 0

    def __new__(self, name, bases, dict) :
        trace(self.t, None)
        self.t = 1
        return type.__new__(self, name, bases, dict)

class A(object, metaclass=Meta) :
    pass

class B(A) :
    pass

trace(2,None)
