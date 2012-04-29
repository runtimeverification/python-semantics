x = False
def h():
  x = 0
  def b():
    global x
    return x
  assert b() == False
  return b
c = h()
assert c() == False
x = 5
assert c() == 5
