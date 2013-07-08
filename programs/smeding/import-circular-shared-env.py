# This test shows that module namespaces are shared, and not statically determined.
# We import a module A, which imports B, that imports A.
# Normally B cannot access A.x because that variable is defined
# after the import of B, but a function body can access A.x as long as it
# is executed after the imports take place.

# see the imported files for more info

# start by importing A, because it will initialize both A and B in the correct order
import imported.imported_circular_shared_env_A
import imported.imported_circular_shared_env_B

assertTrue(imported.imported_circular_shared_env_B.foo() == 1)
