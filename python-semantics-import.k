require "python-semantics-boolean-ops.k"
require "python-semantics-builtin-modules.k"

module PYTHON-SEMANTICS-IMPORT
  imports PYTHON-SEMANTICS-BOOLEAN-OPS
  imports PYTHON-SEMANTICS-BUILTIN-MODULES

  syntax K ::= bootstrap(Exp, Set) [strict(1)]
              | makeSymbol(String, Exp) [strict(2)]
              | doImportlib(Exp) [strict]

  // importlib

  rule importlib => doImportlib({.KeyData})
  rule <k> doImportlib(Dict:Object) => executeModule(codeObject(String2Id("importlib._bootstrap"), .Parameters, Importlib, moduleobject), ref("builtins"), Dict) ~> Dict["_install"](ref("sys"), ref("_imp")) ; ~> ref("builtins") . String2Id("__import__") = Dict["__import__"]::Exp ...</k>
       <importlib> Importlib </importlib>

  rule (. => Dict[S] = ref(S)) ~> bootstrap(Dict, (SetItem(S) => .) _)
  rule bootstrap(_, .) => .

  rule [makeSymbol]: <k> makeSymbol(S, O:Object) => . ...</k>
       <symbols>... . => S |-> id(O) ...</symbols>

  rule invokeBuiltin(obj("imp_acquire_lock",_), ., .) => ref("None")
  rule invokeBuiltin(obj("imp_release_lock",_), ., .) => ref("None")
  rule invokeBuiltin(obj("imp_extension_suffixes",_), ., .) => [.Exps]
  rule <k> invokeBuiltin(obj("imp_is_builtin",_), ListItem(O), .) => test(istype(O, ref("str")), bool(strvalue(O) in keys(M)), raiseInternal("TypeError", "must be str")) ...</k>
       <builtinModules> M </builtinModules>
  rule <k> invokeBuiltin(obj("imp_init_builtin",_), ListItem(O), .) => test(istype(O, ref("str")), test(strvalue(O) in keys(M), ref("sys") . String2Id("modules")[strvalue(O)] = ref(M(strvalue(O))) ~> ref(M(strvalue(O))), ref("None")), raiseInternal("TypeError", "must be str"))  ...</k>
       <builtinModules> M </builtinModules>
  rule invokeBuiltin(obj("imp_is_frozen",_), ListItem(O), .) => test(istype(O, ref("str")), ref("False"), raiseInternal("TypeError", "must be str"))
  rule invokeBuiltin(obj("imp_init_frozen",_), ListItem(O), .) => test(istype(O, ref("str")), ref("None"), raiseInternal("TypeError", "must be str"))
  rule invokeBuiltin(obj("imp_get_frozen_object",_), ListItem(O), .) => test(istype(O, ref("str")), raiseInternal("ImportError", "no such frozen object named " +String strvalue(O)), raiseInternal("TypeError", "must be str"))
  rule invokeBuiltin(obj("imp_is_frozen_package",_), ListItem(O), .) => test(istype(O, ref("str")), raiseInternal("ImportError", "no such frozen object named " +String strvalue(O)), raiseInternal("TypeError", "must be str"))

  rule invokeBuiltin(obj("module.__new__",_), ListItem(Cls) L:List, M:Map) => newHelper(Cls, ref("module"), .) ~> mutable("__dict__" |-> ref("None"), Cls)
  rule invokeBuiltin(obj("module.__init__",_), ListItem(Self:Object) ListItem(Name:Object), .) => ref("module.__init__")(Self, Name, ref("None"))
  rule invokeBuiltin(obj("module.__init__",_), ListItem(Self:Object) ListItem(Name:Object) ListItem(Doc:Object), .) => setref(id(Self), "__dict__", {.KeyData}) ~> ref(id(Self)) . __dict__ ["__name__"] = Name ~> ref(id(Self)) . __dict__ ["__doc__"] = Doc ~> ref("None")

  // import statement

  rule (. => moduleTarget(Module) = doImport(Module, .Aliases) ) ~> import (Module:Alias , Rest => Rest)
  rule import .Aliases => .

  rule from Module:RelativeModule import Fromlist:Aliases => tuple(moduleTargets(Fromlist)) = tuple(importFrom(doImport(Module, Fromlist), moduleNameIds(Fromlist)))

  syntax ObjRef ::= doImport(K, K)
  rule doImport(Module, Fromlist) => ref("builtins") . String2Id("__import__") (moduleName(Module), ref("globals")(.Arguments), ref("locals")(.Arguments), test(Fromlist ==K .Aliases, ref("None"), tuple(moduleNames(Fromlist))), moduleLevel(Module))

  syntax Target ::= moduleTarget(K) [function]
  rule moduleTarget(_ as Name) => Name
  rule moduleTarget(Module . _) => moduleTarget(Module)
  rule moduleTarget(Name:Id) => Name

  syntax String ::= moduleName(K) [function]
  rule moduleName(Module as _) => moduleName(Module)
  rule moduleName(Module . Name) => moduleName(Module) +String "." +String Id2String(Name)
  rule moduleName('.(.KList)) => ""
  rule moduleName(. Module) => moduleName(Module)
  rule moduleName(Name:Id) => Id2String(Name)

  syntax Int ::= moduleLevel(K) [function]
  rule moduleLevel('.(.KList)) => 1
  rule moduleLevel(. Module) => moduleLevel(Module) +Int 1
  rule moduleLevel(_ as _) => 0
  rule moduleLevel(_:Exp) => 0

  syntax Exps ::= moduleNames(Aliases) [function]
  rule moduleNames(Module, Rest) => moduleName(Module) , moduleNames(Rest)
  rule moduleNames(.Aliases) => .Exps

  syntax Targets ::= moduleTargets(Aliases) [function]
  rule moduleTargets(Module, Rest) => moduleTarget(Module) , moduleTargets(Rest)
  rule moduleTargets(.Aliases) => .Targets

  syntax Exps ::= moduleNameIds(Aliases) [function]
  rule moduleNameIds(Name:Id, Rest) => Name , moduleNameIds(Rest)
  rule moduleNameIds(Name:Id as _, Rest:Aliases) => Name , moduleNameIds(Rest)
  rule moduleNameIds(.Aliases) => .Exps

  syntax Exps ::= importFrom (Exp, Exps) [strict(1)]
  rule importFrom(O:Object, Name:Id , Rest) => O . Name , importFrom(O, Rest)
  rule importFrom(_, .Exps) => .Exps

endmodule
