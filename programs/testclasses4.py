exec("""
class A: pass

assert A.__module__ == "builtins"
""", {})
