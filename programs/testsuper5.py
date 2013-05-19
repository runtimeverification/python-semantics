class A:
  __thisclass__ = 5
  def a(self):
    assert self.x == 0
    global y
    y = 5

class B(A):
  def a(self):
    assert self.x == 1
    self.x = 0
    super().a()

b = B()
assert super(B, b).__thisclass__ == 5
assert super(B, b).__self__ is b

class C(A):
  def a(self):
    assert self.x == 2
    self.x = 1
    super().a()

class D(C, B):
  def a(self):
    assert self.x == 3
    self.x = 2
    super().a()
    assert super().__class__ is super

d = D()
d.x = 3
d.a()
assert y == 5
