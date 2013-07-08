class A(int):
  def __new__(cls):
    return 5.0
  def __init__(self):
    assert False

assert A().__class__ is float
