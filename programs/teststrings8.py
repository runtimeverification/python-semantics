assert ",".join([]) == ""
assert ",".join(["foo"]) == "foo"
assert ",".join(["foo", "bar", "baz"]) == "foo,bar,baz", ",".join(["foo", "bar", "baz"])

try:
  ",".join(5)
except TypeError:
  try:
    ",".join([5])
  except TypeError:
     x = 5

assert x == 5
