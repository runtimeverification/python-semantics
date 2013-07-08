class A: pass

assert "__iter__" in A.__dict__.__class__.__dict__
