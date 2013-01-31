class A:
  def __format__(self, spec):
    assert spec == ":!.[]rsa123", spec
    return ""

assert format(A(), ":!.[]rsa123") == ""
assert "{::!.[]rsa123}".format(A()) == ""
