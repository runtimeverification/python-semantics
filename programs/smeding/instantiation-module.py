# module members are not instantiated

import imported.imported_instantiation_module

expectException(TypeError)
imported.imported_instantiation_module.foo()
