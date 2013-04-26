import errno

for err in dir(errno):
  if err[0] == "E":
    print('"errno.' + err + '" |-> ' + str(errno.__dict__[err]) + ' ', end="")
