# this is imported by a test in imports
# importing oneself does not actually create a loop
# this does seem a bit strange though, as the same error does not occur for a circular import

import imported.imported_self

imported.imported_self # imported_self is not yet bound at this point
