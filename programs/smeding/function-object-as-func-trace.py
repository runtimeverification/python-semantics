# check what the exact order of evaluation is when executing an object with
# the call attribute set

class CallableObject(object) :
	def __call__(self, arg) :
		return trace(2, None)

	# the attribute is not actually obtained using this
	#TODO: perhaps it does use the metatype's getattribute?
	def __getattribute__(self, attr) :
		fail()

trace(0,CallableObject())(trace(1,None))
