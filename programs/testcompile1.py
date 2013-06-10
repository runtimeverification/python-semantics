try:
  compile("5", 5, "eval")
  assert False
except TypeError:
  try:
    compile("5", "foo", 5)
    assert False
  except TypeError:
    try:
      compile("5", "foo", "eval", "foo")
      assert False
    except TypeError:
      try:
        compile("5", "foo", "eval", 0, "foo")
        assert False
      except TypeError:
        try:
          compile("5", "foo", "eval", 0, 0, "foo")
          assert False
        except TypeError:
          try:
            compile("5", "foo", "eval", 0, 0, 3)
            assert False
          except ValueError:
            try:
              compile("5", "foo", "eval", 0, 0, -2)
              assert False
            except ValueError:
              try:
                compile("5", "foo", "foo")
                assert False
              except ValueError:
                try:
                  compile(5, "foo", "eval")
                  assert False
                except TypeError:
                  try:
                    compile("\x00", "foo", "eval")
                    assert False
                  except TypeError: pass
