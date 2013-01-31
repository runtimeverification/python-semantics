assert "!:.[]rsa123<>=^+- #0,%bcd".format() == "!:.[]rsa123<>=^+- #0,%bcd"
assert "{{}}".format() == "{}"
assert "{}{}{}{foo}".format("1", "2", "3", foo="4") == "1234"
assert "{2}{0}{1}{foo}".format("2", "3", "1", foo="4") == "1234"
assert "{[0]}".format(("5",)) == "5"
assert "{[foo]}".format({"foo": "5"}) == "5"

class A:
  x = "5"

assert "{.x}".format(A) == "5"

class A:
  x = ["0", "1", "2", {"foo": "5"}]

assert "{1[2].x[3][foo]}".format("0", ["0", "1", A]) == "5"
assert "{:>5.1s}".format("12345") == "    1"
