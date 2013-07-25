require "python-visitor.k"
require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-FUNCTIONS
  imports PYTHON-VISITOR
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax K ::= "makeFunction" "(" Int "," List "," K "," Bool ")"
             | "makeCodeObject" "(" Int "," List "," K "," Bool ")"
  syntax String ::= "paramName" "(" Argument ")"

  rule paramName(X:Id) => Id2String(X)
  rule paramName(X = _) => Id2String(X)
  rule paramName(* X:Id) => Id2String(X)
  rule paramName(** X) => Id2String(X)

  syntax ObjRef ::= "function" "(" Parameters "," Exp "," K ")" [strict(2)]

  rule [evaluate-function-object]: <k> function(Ps:K, O:Object, Return:K) =>
           setref(N, "__doc__", (O . String2Id("co_consts") [0])) ~> 
           setref(N, "__name__", O . String2Id("co_name")) ~> 
           setref(N, "__module__", (ref("globals")(.Arguments) . String2Id("get")("__name__"))) ~> 
           setref(N, "__defaults__", ref("None")) ~>
           setref(N, "__globals__", (ref("globals")(.Arguments))) ~> 
           setref(N, "__dict__", {.KeyData}) ~> 
           setref(N, "__closure__", ref("None")) ~>
           setref(N, "__annotations__", {.KeyData}) ~> 
           setref(N, "__kwdefaults__", ref("None")) ~>
           setref(N, "__frame__", ref(N2)) ~>
           makeFunction(N, Listify(Ps), Return, false) ~> ref(N) ...</k>
       <nextLoc> N:Int => N +Int 1 </nextLoc>
       <frameObject> N2 </frameObject>
       (. => <object>
         <id>N</id>
         <oattrs> "__code__" |-> ref(id(O)) "__class__" |-> ref("function") </oattrs>
       </object>) [allocation]

  rule <k> codeObject(X, Ps, Ss:K, T:CodeObjectType) =>
           setref(N, "co_varnames", tuple(.Exps)) ~>
           setref(N, "co_consts", tuple(docString(Ss))) ~>
           makescope(N, T) ~>
           makeCodeObject(N, Listify(Ps), Ss, false) ~> ref(N) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "co_name" |-> Id2String(X) "co_argcount" |-> 0 "co_kwonlyargcount" |-> 0 "co_nlocals" |-> 0 "__class__" |-> ref("code") "co_flags" |-> 0 </oattrs>
       ...</object>) [allocation]
       

  context makeFunction(_, (ListItem((X:NAME = HOLE)::Argument) _:List), _, _)
  context makeFunction(_, (_:List ListItem(_:Argument : HOLE) _:List), _, _)
  context makeFunction(_, (ListItem((X = HOLE)::Argument : _) _:List), _, _)
  context makeFunction(_, (_:List ListItem((X = _)::Argument : HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem((* _:Exp) : HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem((** _) : HOLE) _:List), _, _) 
  context makeFunction(_, _, HOLE, _)

  rule <k> (. => addParam(X)) ~> makeCodeObject(N, (ListItem(X:NAME) L:List => L), _, false) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_argcount" |-> (N2:Int => N2 +Int 1) "co_nlocals" |-> (N3:Int => N3 +Int 1) ...</oattrs>
       ...</object>

  rule <k> (. => addParam(X)) ~> makeCodeObject(N, (ListItem(X:NAME) L:List => L), _, true) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_nlocals" |-> (N2 => N2 +Int 1) "co_kwonlyargcount" |-> (N3 => N3 +Int 1) ...</oattrs>
       ...</object>

  rule makeCodeObject(_, ((ListItem((X:NAME = _)::Argument) => ListItem(X)) _), _, _)

  rule [makeFunction-defaults]: (. => setref(N, "__defaults__", test(plbool(getref2(ref(N), "__defaults__") is ref("None")), tuple(O), (getref2(ref(N), "__defaults__") + tuple(O))))) ~> makeFunction(N, ((ListItem((X:NAME = O:Object)::Argument) => ListItem(X)) _), _, false)
  rule [makeFunction-kwdefaults]: (. => test(plbool(getref2(ref(N), "__kwdefaults__") is ref("None")), setref(N, "__kwdefaults__", {Id2String(X) : O}), (getref2(ref(N), "__kwdefaults__")[Id2String(X)] = O))) ~> makeFunction(N, ((ListItem((X:Id = O:Object)::Argument) => ListItem(X)) _), _, true)
  rule [makeFunction-parameter]: makeFunction(_, ((ListItem(X:Id) => .) _), _, _)

  rule (. => setattr(N, "co_flags", (getattr(ref(N), "co_flags") |Int 4)) ~> addParam(* X:NAME ::Exp)) ~> makeCodeObject(N, ((ListItem(* X ::Exp) => ListItem(*)) L), _, false) 
  context setattr(_, _, (getattr(HOLE, _) |Int _:Int))
  rule [makeFunction-vararg]: makeFunction(N, ((ListItem(* X:NAME ::Exp) => ListItem(*)) L), _, _)
  rule makeFunction(_, ((ListItem(*) => .) L), _, (false => true))
  rule makeCodeObject(_, ((ListItem(*) => .) L), _, (false => true))
  rule (. => setattr(N, "co_flags", (getattr(ref(N), "co_flags") |Int 8)) ~> addParam(** X)) ~> makeCodeObject(N, ((ListItem(** X:NAME) => .) L), _, _)
  rule makeFunction(N, ((ListItem(** X) => .) L), _, _)
  rule (. => getref2(ref(N), "__annotations__")[paramName(Arg)] = O) ~> makeFunction(N, ((ListItem(Arg:Argument : O:Object) => ListItem(Arg)) _), _, _) 
  rule (. => getref2(ref(N), "__annotations__")["return"] = O) ~> makeFunction(N, _, (O:Object => .Obj), _) 
  rule makeCodeObject(N, ((ListItem(Arg:Argument : _) => ListItem(Arg)) _), _, _)

  syntax ObjRef ::= "makeClosure" "(" Exp ")" [strict]
                  | "cellNum" "(" Exp "," Exp "," Exp ")" [strict]

  rule [dissolve-makeFunction]: makeFunction(N, ., .Obj, _) => setref(N, "__closure__", makeClosure(ref(N) . String2Id("__code__") . String2Id("co_freevars")))
  rule makeClosure(O:Object) => makeClosure(list(listvalue(O)))
  rule makeClosure(list(.)) => tuple(.Exps)
  rule <k> makeClosure(list(ListItem(N) L)) => tuple((getref2(ref(Frame), "f_cells")[N])) + makeClosure(list(L)) ...</k>
       <frameObject> Frame:Int </frameObject>

  syntax K ::= createFunction(Id, K, K, Exp) [strict(4)]
             | createLambda(K, Exp) [strict(2)]
             | createClass(Id, K, Exp) [strict(3)]
             | createGenerator(Exp) [strict]
             | comprehension(Exp, Comps) [function]
             | makescope(K, CodeObjectType)
             | "storescope"
             | "propscope"
             | "delscope"

  syntax K ::= scope(K , Set, Set, Set, Set, Set, List, CodeObjectType, Bool)

  rule <k> makescope (K, T:CodeObjectType) => . ...</k>
       <scope> . => ListItem(scope(ref(K), .Set, .Set, .Set, .Set, .Set, .List, T, false)) ...</scope>

  rule <k> visited(_) ~> storescope => . ...</k>
       <scope> ListItem(scope(.K, _:Set, _:Set, _:Set, _:Set, _:Set, _:List, _, _)) ...</scope>

  rule [storescope]: <k> visited(K) ~> storescope => 
           setattr(N, "co_code", K) ~>
           setref(N, "co_freevars", tuple(DeListify(DeSetify(
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) -Set 
             LOCAL(Defs, Globals, Nonlocals, Params, Type))))) ~>
           setref(N, "co_cellvars", tuple(DeListify(DeSetify(
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) &Set
             LOCAL(Defs, Globals, Nonlocals, Params, Type))))) ~>
           setref(N, "co_varnames", tuple(DeListify(PARAMS(Params) DeSetify(
             (LOCAL(Defs, Globals, Nonlocals, Params, Type) -Set
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L)) -Set
             Setify(PARAMS(Params)))))) ~>
           setref(N, "co_names", tuple(DeListify(DeSetify(
             ((Defs Uses Globals) -Set
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L)) -Set
             LOCAL(Defs, Globals, Nonlocals, Params, Type))))) ~>
           setref(N, "co_globals", tuple(DeListify(DeSetify(Globals)))) ~>
           setref(N, "co_nonlocals", tuple(DeListify(DeSetify(Nonlocals)))) ~>
           setattr(N, "co_type", Type ==K typeobject) ~>
           #if T #then setattr(N, "co_flags", getattr(ref(N), "co_flags") |Int 32) #else . #fi ...</k>
       <scope> ListItem(scope(ref(N), Defs:Set, Uses:Set, Nonlocals:Set, Globals:Set, ChildFree:Set, Params:List, Type, T:Bool)) L</scope>

  rule <k> propscope => . ...</k>
       <scope> LI:ListItem </scope>
  rule <k> propscope => . ...</k>
       <scope> ListItem(scope(_, Defs, Uses, Nonlocals, Globals, ChildFree, Params, Type, _)) ListItem(scope(ref(N), Defs2:Set, Uses2:Set, Nonlocals2:Set, Globals2:Set, ChildFree2:Set (. => (FREE(Defs, Uses, Globals, Nonlocals, ChildFree, ListItem(scope(N, Defs2, Uses2, Nonlocals2, Globals2, ChildFree2, Params2, T, T2)) L)) -Set LOCAL(Defs, Globals, Nonlocals, Params, Type)), Params2:List, T, T2)) L </scope>

  rule <k> delscope => . ...</k>
       <scope> LI:ListItem => . ...</scope>

  syntax Set ::= FREE(Set, Set, Set, Set, Set, List) [function]
  syntax Set ::= LOCAL(Set, Set, Set, List, CodeObjectType) [function]
  syntax Set ::= BOUND(Set, List) [function]
  syntax List ::= PARAMS(List) [function]
  rule LOCAL(Defs, Globals, Nonlocals, Params, Type) => ((Defs Setify(PARAMS(Params))) -Set Globals) -Set Nonlocals when Setify(PARAMS(Params)) &Set Nonlocals ==Set . andBool Setify(PARAMS(Params)) &Set Globals ==Set . andBool Type =/=K typeobject
  rule LOCAL(_, Globals, Nonlocals, _, typeobject) => (SetItem("__class__") -Set Globals) -Set Nonlocals
  rule FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) => Nonlocals ChildFree (((Uses) &Set BOUND(.,L)) -Set Globals) when (Nonlocals &Set BOUND(., L)) ==Set Nonlocals andBool notBool "super" in Uses
  rule FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) => Nonlocals ChildFree (((Uses SetItem("__class__")) &Set BOUND(.,L)) -Set Globals) when (Nonlocals &Set BOUND(., L)) ==Set Nonlocals andBool "super" in Uses
  rule BOUND(Bound:Set, L ListItem(scope(_, Defs, _, Nonlocals, Globals, _, Params, funcobject, _))) => BOUND((Bound LOCAL(Defs, Globals, Nonlocals, Params, funcobject)) -Set Globals, L) 
  // if we are computing what is bound by a class definition scope, the only thing bound is __class__. Nothing in the local environment is bound.
  rule BOUND(Bound:Set, L ListItem(scope(_, _:Set, _:Set, _:Set, Globals:Set, _:Set, _:List, typeobject, _))) => BOUND(Bound SetItem("__class__"), L) when notBool "__class__" in Globals
  rule BOUND(Bound:Set, L ListItem(scope(_, _:Set, _:Set, _:Set, Globals:Set, _:Set, _:List, moduleobject, _))) => BOUND(Bound, L)
  rule BOUND(Bound, .) => Bound 
  rule PARAMS(ListItem(X:Id) Params) => ListItem(Id2String(X)) PARAMS(Params) 
  rule PARAMS(ListItem(* X:Exp) Params) => PARAMS(Params ListItem(* X)) when Params =/=List . 
  rule PARAMS(ListItem(** X:Id) ListItem(* (Y:Id)::Exp)) => ListItem(Id2String(Y)) ListItem(Id2String(X)) 
  rule PARAMS(ListItem(* (X:Id)::Exp)) => ListItem(Id2String(X)) 
  rule PARAMS(ListItem(** X:Id)) => ListItem(Id2String(X)) 
  rule PARAMS(ListItem(* (X:Id)::Exp) ListItem(** Y:Id)) => ListItem(Id2String(X)) ListItem(Id2String(Y)) 
  rule PARAMS(.) => . 

  rule createFunction(X:Id, Ps, K:K, O:Object) => visited((X)::Target = function(Ps, O, K))
  rule createLambda(Ps, O:Object) => visited(function(Ps, O, .Obj))
  rule createClass(X:Id, As, O:Object) => visited((X)::Target = class(As, O))
  rule createGenerator(O:Object) => visited(function(.Parameters, O, .Obj)(.Arguments))

  rule comprehension(E, for T in E2 Comps ::Comps) => for T in E2 : comprehension(E, Comps)
  rule comprehension(E, if E2 Comps ::Comps) => if E2 : comprehension(E, Comps)
  rule comprehension(E, .Comps) => yield E ;

  rule makeCodeObject(N, ., Ss, _) => visit(Ss, 'optimizeVisitor) ~> visit(Ss, 'compileVisitor) ~> visit(Ss, 'childScopeVisitor) ~> visit(Ss, 'syntaxCheckerVisitor) ~> storescope ~> propscope ~> delscope
  rule (visited(Ss) => .) ~> visit((_ => Ss), 'compileVisitor)
  rule (visited(Ss) => .) ~> visit((_ => Ss), 'childScopeVisitor)
  rule (visited(Ss) => .) ~> visit((_ => Ss), 'syntaxCheckerVisitor)
 
  syntax K ::= compileVisitor(KLabel, Int, K)
             | parameterVisitor(KLabel, Int, K)
             | bindVisitor(KLabel, Int, K)
             | importVisitor(KLabel, Int, K)
             | withVisitor(KLabel, Int, K)
             | childScopeVisitor(KLabel, Int, K)
             | syntaxCheckerVisitor(KLabel, Int, K)
             | optimizeVisitor(KLabel, Int, K)

  syntax K ::= addDef(Id)
             | addUse(Id)
             | addNonlocals(NAMES)
             | addGlobals(NAMES)
             | addParam(Parameter)
             | "setGenerator"

  rule <k> addDef(X) => . ...</k>
       <scope> ListItem(scope(_, _ (. => SetItem(Id2String(X))), _, _, _, _, _, _, _)) ...</scope>

  rule <k> addUse(X) => . ...</k>
       <scope> ListItem(scope(_, _, _ (. => SetItem(Id2String(X))), _, _, _, _, _, _)) ...</scope>

  rule <k> addNonlocals(X , Xs => Xs) ...</k>
       <scope> ListItem(scope(_, _, _, _ (. => SetItem(Id2String(X))), _, _, _, _, _)) ...</scope>

  rule <k> addGlobals(X, Xs => Xs) ...</k>
       <scope> ListItem(scope(_, _, _, _, _ (. => SetItem(Id2String(X))), _, _, _, _)) ...</scope>

  rule <k> addParam(K) => . ...</k>
       <scope> ListItem(scope(_, _:Set, _:Set, _:Set, _:Set, _:Set, _ (. => ListItem(K)), _, _)) ...</scope>

  rule <k> setGenerator => . ...</k>
       <scope> ListItem(scope(_, _:Set, _:Set, _:Set, _:Set, _:Set, _, _, (_ => true))) ...</scope>

  rule addGlobals(.NAMES) => .
  rule addNonlocals(.NAMES) => .

  rule compileVisitor('import_, 0, K) => visit(K, 'importVisitor)
  rule compileVisitor('from_import_, 0, K) => visited(K)
  rule compileVisitor('from_import_, 1, K) => visit(K, 'importVisitor)
  rule importVisitor('_._, 1, K) => visited(K)
  rule importVisitor('_as_, 0, K) => visited(K)
  rule importVisitor(Lbl:KLabel, N, K) => visit(K, 'importVisitor) when notBool((N ==Int 1 andBool Lbl ==KLabel '_._) orBool (N ==Int 0 andBool Lbl ==KLabel '_as_)) andBool N =/=Int -1
  rule importVisitor(returner, -1, X:Id) => visit(X, 'bindVisitor)
  rule importVisitor(returner, -1, K) => visited(K) when isId(K) =/=K true

  rule compileVisitor('def_`(_`):_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('def_`(_`):_, 1, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('def_`(_`):_, 2, Ss) => visited(Ss)
  rule childScopeVisitor('def_`(_`):_, N, K) => visited(K)
  rule childScopeVisitor(returner, -1, (def X (Ps): Ss)) => createFunction(X, Ps, .Obj, codeObject(X, Ps, Ss, funcobject))
  rule compileVisitor('def_`(_`)->_:_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('def_`(_`)->_:_, 1, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('def_`(_`)->_:_, 3, Ss) => visited(Ss)
  rule childScopeVisitor('def_`(_`)->_:_, N, K) => visited(K)
  rule childScopeVisitor(returner, -1, (def X (Ps)-> K : Ss)) => createFunction(X, Ps, K, codeObject(X, Ps, Ss, funcobject))

  rule compileVisitor('lambda_:_, 0, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('lambda_:_, 1, K) => visited(K)
  rule childScopeVisitor('lambda_:_, N, K) => visited(K)
  rule childScopeVisitor(returner, -1, (lambda Ps : K)) => createLambda(Ps, codeObject(String2Id("<lambda>"), Ps, return K, funcobject))

  rule compileVisitor('GeneratorExp, N, K) => visited(K)
  rule childScopeVisitor('GeneratorExp, N, K) => visited(K)
  rule childScopeVisitor(returner, -1, generator(E Comp)) => createGenerator(codeObject(String2Id("<genexpr>"), .Parameters, comprehension(E, Comp), funcobject))

  rule parameterVisitor('_=_,1,K) => visit(K, 'compileVisitor)
  rule parameterVisitor('_:_,1,K) => visit(K, 'compileVisitor)
  rule parameterVisitor(Lbl, N, K) => visit(K, 'parameterVisitor) when notBool(N ==Int 1 andBool (Lbl ==KLabel '_=_ orBool Lbl ==KLabel '_:_)) andBool N =/=Int -1
  rule parameterVisitor(returner, -1, K) => visited(K)

  rule compileVisitor('class_`(_`):_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('class_`(_`):_, 2, Ss) => visited(Ss)
  rule childScopeVisitor('class_`(_`):_, N, K) => visited(K)
  rule childScopeVisitor(returner, -1, (class X (As:K): Ss)) => createClass(X, As, codeObject(X, .Parameters, Ss, typeobject))

  rule compileVisitor(returner, -1, (yield E)) => setGenerator ~> visited(yield E)

  rule compileVisitor('_=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_+=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_-=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_*=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_/=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_FloorDiv=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_%=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_**=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_>>=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_<<=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_&=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_^=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_|=_,0,K) => visit(K, 'bindVisitor)

  rule compileVisitor('for_in_:_else:_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('with_:_,0,K) => visit(K, 'withVisitor)
  rule compileVisitor('except_as_:_,1,K) => visit(K, 'bindVisitor)
  rule compileVisitor('del_,0,K) => visit(K, 'bindVisitor)

  rule compileVisitor('global_,0,Xs:NAMES) => addGlobals(Xs) ~> visited(Xs)
  rule compileVisitor('nonlocal_,0,Xs:NAMES) => addNonlocals(Xs) ~> visited(Xs)

  rule compileVisitor(returner, -1, X:Id) => addUse(X) ~> visited(X)
  rule compileVisitor('_=_, 0, K) => visited(K)

  rule withVisitor('_as_, 0, K) => visit(K, 'compileVisitor)
  rule withVisitor('_as_, 1, K) => visit(K, 'bindVisitor)
  rule withVisitor(Lbl, N, K) => visit(K, 'compileVisitor) when notBool(Lbl ==KLabel '_as_) andBool N =/=Int -1
  rule withVisitor(returner, -1, K) => visited(K)

  rule bindVisitor('_._, 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_._, 1, K) => visited(K)
  rule bindVisitor('_`[_`], 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_`[_`], 1, K) => visited(K)
  rule bindVisitor('_as_, 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_as_, 1, K) => visited(K)
  rule bindVisitor(Lbl, N, K) => visit(K, 'bindVisitor) when notBool(Lbl ==KLabel '_as_ orBool Lbl ==KLabel '_._ orBool Lbl ==KLabel '_`[_`]) andBool N =/=Int -1
  rule bindVisitor(returner, -1, X:Id) => addDef(X) ~> visited(X)
  rule bindVisitor(returner, -1, K) => visited(K) when isId(K) =/=K true

  rule childScopeVisitor(Lbl, N, K) => visit(K, 'childScopeVisitor) when notBool (Lbl ==KLabel 'def_`(_`)->_:_ orElseBool Lbl ==KLabel 'class_`(_`):_ orElseBool Lbl ==KLabel 'def_`(_`):_ orElseBool Lbl ==KLabel 'lambda_:_ orElseBool Lbl ==KLabel 'GeneratorExp) andBool N =/=Int -1
  rule compileVisitor(Lbl, N, K) => visit(K, 'compileVisitor) when notBool ((Lbl ==KLabel 'def_`(_`)->_:_ andBool N =/=Int 2) orElseBool (Lbl ==KLabel 'class_`(_`):_ andBool N =/=Int 1) orElseBool (N ==Int 0 andBool (Lbl ==KLabel '_=_ orElseBool Lbl ==KLabel '_+=_ orElseBool Lbl ==KLabel '_-=_ orElseBool Lbl ==KLabel '_*=_ orElseBool Lbl ==KLabel '_/=_ orElseBool Lbl ==KLabel '_FloorDiv=_ orElseBool Lbl ==KLabel '_%=_ orElseBool Lbl ==KLabel '_**=_ orElseBool Lbl ==KLabel '_>>=_ orElseBool Lbl ==KLabel '_<<=_ orElseBool Lbl ==KLabel '_&=_ orElseBool Lbl ==KLabel '_^=_ orElseBool Lbl ==KLabel '_|=_)) orElseBool (Lbl ==KLabel 'for_in_:_else:_ andBool N ==Int 0) orElseBool (Lbl ==KLabel 'with_:_ andBool N ==Int 0) orElseBool (Lbl ==KLabel 'except_as_:_ andBool N ==Int 1) orElseBool Lbl ==KLabel 'del_ orElseBool Lbl ==KLabel 'global_ orElseBool Lbl ==KLabel 'nonlocal_ orElseBool (Lbl ==KLabel '_=_ andBool N ==Int 0) orElseBool Lbl ==KLabel 'import_ orElseBool Lbl ==KLabel 'from_import_ orElseBool Lbl ==KLabel 'def_`(_`):_ orElseBool Lbl ==KLabel 'lambda_:_ orElseBool Lbl ==KLabel 'GeneratorExp) andBool N =/=Int -1

  rule <k> syntaxCheckerVisitor('return_, 0, K) => #if Type:CodeObjectType ==K funcobject #then visit(K, 'syntaxCheckerVisitor) #else raiseInternal("SyntaxError", "return outside function") #fi ...</k>
       <scope> ListItem(scope(_, _, _, _, _, _, _, Type, _)) ...</scope>
  rule syntaxCheckerVisitor(Lbl, N, K) => visit(K, 'syntaxCheckerVisitor) when notBool(Lbl ==KLabel 'return_) andBool N =/=Int -1
  rule syntaxCheckerVisitor(returner, -1, K) => visited(K)

  rule compileVisitor(returner, -1, K) => visited(K) when isId(K) =/=K true andBool getKLabel K =/=KLabel 'yield_
  rule childScopeVisitor(returner, -1, K) => visited(K) when getKLabel K =/=KLabel 'def_`(_`)->_:_ andBool getKLabel K =/=KLabel 'def_`(_`):_ andBool getKLabel K =/=KLabel 'class_`(_`):_
  rule compileVisitor(returner, -1, .) => visited(.)
  rule childScopeVisitor(returner, -1, .) => visited(.)

  rule <k> optimizeVisitor(returner, -1, if __debug__ : Ss else: Ss2) => visited(#if N ==Int 0 #then Ss #else Ss2 #fi) ...</k>
       <optimize> N </optimize>
  rule optimizeVisitor(Lbl, N, K) => visit(K, 'optimizeVisitor) when N =/=Int -1
  rule optimizeVisitor(returner, -1, if K:K : Ss else: Ss2) => visited(if K : Ss else: Ss2) when K =/=K __debug__
  rule optimizeVisitor(returner, -1, K) => visited(K) when getKLabel K =/=KLabel 'if_:_else:_ andBool isId(K) =/=K true
  rule optimizeVisitor(returner, -1, X:Id) => visited(ref(Id2String(X))) when Id2String(X) in keywords
  rule optimizeVisitor(returner, -1, X:Id) => visited(X) when notBool Id2String(X) in keywords

  syntax Set ::= "keywords" [function]
  rule keywords => SetItem("True") SetItem("False") SetItem("None")

endmodule
