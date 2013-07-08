# an import statement gets everything that is in scope, also modules imported
# by an imported module

import imported.imported_re_export_imported_A

# also note the naming
assertTrue(imported.imported_re_export_imported_A.imported.imported_re_export_imported_B.x == 1)
