# when constructing a new dictionary with an instance, the instance is not shared

a = {"x" : 1}
b = dict(a)

b["x"] = 2

assertTrue(a["x"] == 1)
