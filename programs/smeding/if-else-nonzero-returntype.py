# if __nonzero__ does not return a boolean, a type error should be raised

class A(object) :
	def __bool__(self) :
		assertTrue(self.cnt < 1)
		self.cnt = self.cnt + 1
		return self

a = A()
a.cnt = 0

expectException(TypeError)

if a :
	fail()
else :
	fail()
