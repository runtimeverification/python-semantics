# type error should be thrown when something other than a string is executed

expectException(TypeError)
exec(1, {})
