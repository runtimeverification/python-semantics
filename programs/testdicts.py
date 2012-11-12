x = {"5": "6", "6": "7"}
assert x["5"] == "6" and x["6"] == "7"
x["7"] = "8"
assert x["7"] == "8"
del x["5"]

try:
  x["5"]
  assert False
except KeyError:
  pass

assert dict(x)["6"] == "7"
