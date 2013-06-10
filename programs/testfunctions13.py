def a(): pass
assert a.__module__ == "__main__"
del __name__
def b(): pass
assert b.__module__ is None
