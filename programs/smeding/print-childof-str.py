# print will call __str__ even for a direct descendant of str

class StrCalledException(Exception) :
    pass

class A(str) :
    def __str__(self) :
        raise StrCalledException()

expectException(StrCalledException)
print((A()))
