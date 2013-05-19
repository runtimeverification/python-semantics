try:
  super()
except SystemError:
  try:
    def a(self):
      super()
    a(1)
  except SystemError:
    try:
      class A:
        def a(self):
          del self
          super()
      A().a()
    except SystemError:
      try:
        class A:
          def a(self):
            nonlocal __class__
            del __class__
            super()
        A().a()
      except SystemError:
        try:
          class A:
            def a(self):
              nonlocal __class__
              __class__ = 5
              super()
          A().a()
        except SystemError:
          x = 5

assert x == 5
