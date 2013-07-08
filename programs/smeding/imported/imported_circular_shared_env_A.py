# start of the circle by import B
import imported.imported_circular_shared_env_B

# the variable x is defined only after the import, but it will be in scope
# when this module is imported by a 3rd module
x = 1

# we could call B.foo here, but the test functions aren't in scope here
