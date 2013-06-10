assert exec("""
x = 5
assert locals()["x"] == 5
assert globals().get("x") is None
""", {}, {}) is None
