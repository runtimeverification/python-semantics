# linking back to A, thus completing the circle
import imported.imported_circular_shared_env_A

# at this point A.x is not yet defined

# foo uses A.x in its body, which is not executed yet
def foo() :
	return imported.imported_circular_shared_env_A.x


# A.x still isn't defined, so a call to foo() would fail here
