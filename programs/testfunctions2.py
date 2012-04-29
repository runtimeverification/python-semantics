def b(* x):
  assert x[0] == 5 and x[1] == 6 and len(x) == 2, x[0] + x[1]

assert b(5, 6) is None
