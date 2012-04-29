try:
  raise Exception from TypeError
except Exception as e:
  assert e.__cause__.__class__ == TypeError

try:
  raise Exception from TypeError()
except Exception as e:
  assert e.__cause__.__class__ == TypeError
