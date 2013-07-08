# one can not import a module inside another module

expectException(ImportError)
import imported.imported_module_in_module_A.imported.imported_module_in_module_B
