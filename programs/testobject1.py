class A: pass

assert "__iter__" in A.__dict__.__class__.__dict__
assert {key : A.__dict__[key] for key in A.__dict__}.__class__ is dict
