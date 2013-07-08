setDescr(" Couldn't access an internal class after declaration")

class A(object) :
    class B(object) :
        x = 1
    y = B.x
