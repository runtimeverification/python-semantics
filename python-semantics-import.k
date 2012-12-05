require "python-semantics-builtin-modules.k"
require "python-semantics-os.k"

module PYTHON-SEMANTICS-IMPORT
  imports PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-OS

  syntax K ::= bootstrap(Expression, Set) [strict(1)]
              | makeSymbol(String, Expression) [strict(2)]
              | doImportlib(Expression) [strict]

  // importlib

  rule importlib => doImportlib({.KeyData}) ~> ref("builtins") . String2Id("__import__"), .Expressions := ref("__import__")
  rule <k> doImportlib(Dict:Object) => Dict["path_sep"], .Expressions := pathSeparator(OS) ~> bootstrap(Dict, SetItem("_imp") SetItem("sys")) ~> executeModule(codeObject(String2Id("importlib._bootstrap"), .Parameters, Importlib, true), ref("builtins"), Dict) ~> makeSymbol("__import__", Dict["__import__"]) ...</k>
       <importlib> Importlib </importlib>
       <os> OS </os>

  rule (. => Dict[S], .Expressions := ref(S)) ~> bootstrap(Dict, (SetItem(S) => .) _)
  rule bootstrap(_, .) => .

  rule <k> makeSymbol(S, O:Object) => . ...</k>
       <symbols>... . => S |-> id(O) ...</symbols>

  rule invokeBuiltin(obj("imp_acquire_lock",_), ., .) => ref("None")
  rule invokeBuiltin(obj("imp_release_lock",_), ., .) => ref("None")
  rule <k> invokeBuiltin(obj("imp_is_builtin",_), ListItem(O), .) => test(istype(O, ref("str")), bool(strvalue(O) in M), raiseInternal("TypeError", "must be str")) ...</k>
       <builtinModules> M </builtinModules>
  rule <k> invokeBuiltin(obj("imp_init_builtin",_), ListItem(O), .) => test(istype(O, ref("str")), test(strvalue(O) in M, ref(M(strvalue(O))), ref("None")), raiseInternal("TypeError", "must be str"))  ...</k>
       <builtinModules> M </builtinModules>
  rule invokeBuiltin(obj("imp_is_frozen",_), ListItem(O), .) => test(istype(O, ref("str")), ref("False"), raiseInternal("TypeError", "must be str"))
  rule invokeBuiltin(obj("imp_init_frozen",_), ListItem(O), .) => test(istype(O, ref("str")), ref("None"), raiseInternal("TypeError", "must be str"))
  rule invokeBuiltin(obj("imp_get_frozen_object",_), ListItem(O), .) => test(istype(O, ref("str")), raiseInternal("ImportError", "no such frozen object named " +String strvalue(O)), raiseInternal("TypeError", "must be str"))
  rule invokeBuiltin(obj("imp_is_frozen_package",_), ListItem(O), .) => test(istype(O, ref("str")), raiseInternal("ImportError", "no such frozen object named " +String strvalue(O)), raiseInternal("TypeError", "must be str"))

  // import statement

  rule (. => moduleTarget(Module), .Expressions := doImport(Module, .ModuleAliases) ) ~> import (Module , Rest => Rest)
  rule import .ModuleAliases => .

  rule from Module:RelativeModule import Fromlist:ModuleAliases => moduleTargets(Fromlist) := tuple(importFrom(doImport(Module, Fromlist), moduleNameIds(Fromlist)))

  syntax ObjRef ::= doImport(K, K)
  rule doImport(Module, Fromlist) => ref("builtins") . String2Id("__import__") (moduleName(Module), ref("globals")(.Arguments), ref("locals")(.Arguments), test(Fromlist ==K .ModuleAliases, ref("None"), tuple(moduleNames(Fromlist))), moduleLevel(Module), .Arguments)

  syntax NAME ::= moduleTarget(K) [function]
  rule moduleTarget(_ as Name) => Name
  rule moduleTarget(Module . _) => moduleTarget(Module)
  rule moduleTarget(Name:Id) => Name

  syntax String ::= moduleName(K) [function]
  rule moduleName(Module as _) => moduleName(Module)
  rule moduleName(Module . Name) => moduleName(Module) +String "." +String Id2String(Name)
  rule moduleName(.dir) => ""
  rule moduleName(. Module) => moduleName(Module)
  rule moduleName(Name:Id) => Id2String(Name)

  syntax Int ::= moduleLevel(K) [function]
  rule moduleLevel(.dir) => 1
  rule moduleLevel(. Module) => moduleLevel(Module) +Int 1
  rule moduleLevel(_ as _) => 0
  rule moduleLevel(_:Expression) => 0

  syntax Expressions ::= moduleNames(ModuleAliases) [function]
  rule moduleNames(Module, Rest) => moduleName(Module) , moduleNames(Rest)
  rule moduleNames(.ModuleAliases) => .Expressions

  syntax Expressions ::= moduleTargets(ModuleAliases) [function]
  rule moduleTargets(Module, Rest) => moduleName(Module) , moduleTargets(Rest)
  rule moduleTargets(.ModuleAliases) => .Expressions

  syntax Expressions ::= moduleNameIds(ModuleAliases) [function]
  rule moduleNameIds(Name:Id, Rest) => Name , moduleNameIds(Rest)
  rule moduleNameIds(Name:Id as _, Rest) => Name , moduleNameIds(Rest)
  rule moduleNameIds(.ModuleAliases) => .Expressions

  syntax Expressions ::= importFrom (Expression, Expressions) [strict(1)]
  rule importFrom(O:Object, Name , Rest) => O . Name , importFrom(O, Rest)
  rule importFrom(_, .Expressions) => .Expressions

endmodule
