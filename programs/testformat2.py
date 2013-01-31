try:
  format("foo", "=")
  assert False
except ValueError:
  try:
    format("foo", "+")
    assert False
  except ValueError:
    try:
      format("foo", "#")
      assert False
    except ValueError:
      try:
        format("foo", "0")
        assert False
      except ValueError:
        try:
          format("foo", ",")
          assert False
        except ValueError:
          try:
            format("foo", "d")
            assert False
          except ValueError:
            try:
              format("foo", "ss")
              assert False
            except ValueError:
              try:
                format("foo", ".")
                assert False
              except ValueError:
                x = 5

assert x == 5
