try:
  x = 5
except TypeError:
  assert False
except SyntaxError as y:
  assert False
else:
  y = 6
  assert x == 5
finally:
  z = 7
  assert y == 6
assert z == 7

try:
  raise
  assert False
except RuntimeError:
  x = 6
finally:
  y = 7
  assert x == 6
assert y == 7

try:
  try:
    raise
  except SyntaxError:
    assert False
  finally:
    x = 7
  assert False
except RuntimeError:
  y = 8
  assert x == 7
assert y == 8

try:
  raise Exception
except Exception as e:
  assert e.__class__ == Exception

try:
  raise Exception()
except Exception as e:
  assert e.__class__ == Exception

try:
  try:
    e
    assert False
  except NameError as e:
    x = 8
    raise
    assert False
except NameError as f:
  try:
    e
    assert False
  except NameError:
    y = 9
assert x == 8 and y == 9

try:
  try:
    raise
    assert False
  except a:
    assert False
except NameError:
  x = 9
assert x == 9

try:
  try:
    raise
    assert False
  finally:
    try:
      raise TypeError
      assert False
    except TypeError as e:
      assert e.__context__.__class__ == RuntimeError
      x = 10
  assert False
except RuntimeError:
  y = 11
  assert x == 10
assert y == 11

try:
  raise Exception from TypeError
except Exception as e:
  assert e.__cause__.__class__ == TypeError

try:
  raise Exception from TypeError()
except Exception as e:
  assert e.__cause__.__class__ == TypeError

try:
  try:
    raise
    assert False
  finally:
    x = 11
  assert False
except RuntimeError:
  y = 12
  assert x == 11
assert y == 12

try:
  try:
    raise
    assert False
  except RuntimeError:
    raise SyntaxError
  assert False
except SyntaxError as e:
  assert e.__context__.__class__ == RuntimeError

try:
  try:
    raise SyntaxError
  except SyntaxError:
    try:
      raise TypeError
    except TypeError: pass
    raise
except SyntaxError:
  x = 12
assert x == 12

try:
  raise None
  assert False
except TypeError:
  x = 13
assert x == 13

try:
  raise SyntaxError from None
  assert False
except TypeError:
  x = 14
assert x == 14
