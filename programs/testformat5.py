try:
  "{".format()
  assert False
except ValueError:
  try:
    "}".format()
    assert False
  except ValueError:
    try:
      "{1{}".format()
      assert False
    except ValueError:
      try:
        "{}{1}".format("1", "2")
        assert False
      except ValueError:
        try:
          "{1}{}".format("1", "2")
          assert False
        except ValueError:
          try:
            "{!rr}".format("1")
            assert False
          except ValueError:
            try:
              "{!d:1}".format("1")
              assert False
            except ValueError:
              x = 5

assert x == 5
