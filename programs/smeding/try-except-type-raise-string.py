# in previous versions (python < 2.5 ?) raising strings was allowed
# TODO: find a safe way to test this

#expectException(TypeError)
#
#try :
#	raise "adsf"
#except str, e :
#	fail()
