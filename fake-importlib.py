def _install(sys_module, _imp_module):
  global _imp, sys
  _imp = _imp_module
  sys = sys_module

def __import__(name, globals=None, locals=None, fromlist=(), level=0):
  return _imp.init_builtin(name)
  
