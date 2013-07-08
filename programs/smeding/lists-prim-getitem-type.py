# getitem for lists only accepts integers and slices

expectException(TypeError)
["x", "foo", "bar"].__getitem__("1")
