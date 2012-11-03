class M2(type):
  def __prepare__(name, bases, **kwargs):
    assert name == "C"
    assert bases == ()
    assert kwargs["x"] == 5
    assert "metaclass" not in kwargs
    return {"a": 1}

  def __new__(cls, name, bases, classdict, **kwargs):
    assert cls == M2
    assert name == "C"
    assert bases == ()
    assert kwargs["x"] == 5
    assert classdict["a"] == 1
    classdict["b"] = 2
    return type.__new__(cls, name, bases, classdict)

  def __init__(self, name, bases, classdict, **kwargs):
    assert name == "C"
    assert bases == ()
    assert classdict["a"] == 1
    assert classdict["b"] == 2
    self.c = 3
    assert kwargs["x"] == 5

class C(metaclass=M2, x=5): pass

assert C.c == 3
