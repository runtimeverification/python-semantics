# see if a descendent of dict can be used for the environment of an exec statement

class MyEnv(dict) :
	pass

env = MyEnv()
env["foo"] = assertTrue

exec("foo(True)", env)
