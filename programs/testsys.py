import sys

assert sys.path[0][-9:] == "/programs", sys.path[0][-9:]
assert sys.argv[0] == "programs/testsys.py"
assert sys.argv[1] == "one"
assert sys.argv[2] == "two"
assert sys.argv[3] == "three four"
