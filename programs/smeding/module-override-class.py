# an imported module can define a variable __class__ but it will never be 
# exported, because it is overridden

import imported.imported_module_override_class

# access __class__ variable in imported module because it is overridden
assertTrue(not (imported.imported_module_override_class.__class__.__class__ is int))
