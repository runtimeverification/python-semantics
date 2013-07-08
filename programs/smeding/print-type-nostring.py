# check whether print raises a type error when doesn't __str__ return a string

def A(object) :
	def __str__(self) :
		return 1

expectException(TypeError)
print((A()))
