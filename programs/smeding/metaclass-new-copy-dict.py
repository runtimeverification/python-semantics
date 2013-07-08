# check if the class-constructor of type copies the dictionary of attributes

dict = {}

A = type.__new__(type, "A", (object,), dict)

dict["spam"] = True

expectException(AttributeError)
A.spam
