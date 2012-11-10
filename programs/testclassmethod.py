@classmethod
def a(x): assert x is int

a.__get__(5, int)()
a.__get__(5, None)()
a.__get__(None, int)()
