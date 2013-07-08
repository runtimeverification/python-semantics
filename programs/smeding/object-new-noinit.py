# object's constructor __new__ does not call __init__

class A(object) :
    def __init__(self) :
        fail()

A.__new__(A)
