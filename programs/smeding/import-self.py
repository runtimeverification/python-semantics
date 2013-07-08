# importing oneself does not actually create a loop

# cant implement this python attribute because it's a test
expectException(AttributeError)
import imported.imported_self
