module PYTHON-SEMANTICS-FUNCTIONS
  imports PYTHON-VISITOR
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax K ::= "makeFunction" "(" Nat "," List "," K "," Bool ")"
             | "makeCodeObject" "(" Nat "," List "," K "," Bool ")"
  syntax String ::= "paramName" "(" Argument ")"

  rule paramName(X:Id) => Id2String(X)
  rule paramName(X = _) => Id2String(X)
  rule paramName(* X) => Id2String(X)
  rule paramName(** X) => Id2String(X)

  syntax ObjRef ::= "function" "(" Parameters "," Expression "," K ")" [:strict(2):]

  rule <k> function(Ps:K, O:Object, Return:K) =>
           setref(N, "__doc__", (O . String2Id("co_consts") [0])) ~> 
           setref(N, "__name__", O . String2Id("co_name")) ~> 
           setref(N, "__module__", (ref("globals")()["__name__"])) ~> 
           setref(N, "__defaults__", ref("None")) ~>
           setref(N, "__globals__", (ref("globals")())) ~> 
           setref(N, "__dict__", {}) ~> 
           setref(N, "__closure__", ref("None")) ~>
           setref(N, "__annotations__", {}) ~> 
           setref(N, "__kwdefaults__", ref("None")) ~>
           setattr(N, "__frame__", N2) ~>
           makeFunction(N, Listify(Ps), Return, false) ~> ref(N) ...</k>
       <nextLoc> N:Nat => N +Int 1 </nextLoc>
       <currentFrame> N2 </currentFrame>
       (. => <object>...
         <id>N</id>
         <oattrs> "__code__" |-> id(O) "__class__" |-> Function </oattrs>
       ...</object>)
       <symbols>... "function" |-> Function:Nat ...</symbols>

  rule <k> codeObject(X, Ps, Ss:K) =>
           setref(N, "co_varnames", tuple()) ~>
           setref(N, "co_consts", tuple(docString(Ss))) ~>
           makescope(N) ~>
           makeCodeObject(N, Listify(Ps), Ss, false) ~> ref(N) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "co_name" |-> Id2String(X) "co_argcount" |-> 0 "co_kwonlyargcount" |-> 0 "co_nlocals" |-> 0 "__class__" |-> Code "co_flags" |-> 0 </oattrs>
       ...</object>)
       <symbols>... "code" |-> Code:Nat ...</symbols>
       

  context makeFunction(_, (ListItem(X = HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem(X : HOLE) _:List), _, _)
  context makeFunction(_, (ListItem((X = HOLE) : _) _:List), _, _)
  context makeFunction(_, (_:List ListItem((X = _) : HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem((*_(_)) : HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem((** _) : HOLE) _:List), _, _) 
  context makeFunction(_, _, HOLE, _)

  //TODO: fix these two rules once we have hooks
  rule <k> (. => addParam(X)) ~> makeCodeObject(N, (ListItem(X) L:List => L), _, false) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_argcount" |-> (N2:Nat => N2 +Int 1) "co_nlocals" |-> (N3:Nat => N3 +Int 1) ...</oattrs>
       ...</object>

  rule <k> (. => addParam(X)) ~> makeCodeObject(N, (ListItem(X) L:List => L), _, true) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_nlocals" |-> (N2 => N2 +Int 1) "co_kwonlyargcount" |-> (N3 => N3 +Int 1) ...</oattrs>
       ...</object>

  rule makeCodeObject(_, ((ListItem(X = _) => ListItem(X)) _), _, _)

  rule (. => setref(N, "__defaults__", test(plbool(getref(ref(N), "__defaults__") is ref("None")), tuple(O), (getref(ref(N), "__defaults__") + tuple(O))))) ~> makeFunction(N, ((ListItem(X = O) => ListItem(X)) _), _, false)
  rule (. => test(plbool(getref(ref(N), "__kwdefaults__") is ref("None")), {Id2String(X) : O}, (getref(ref(N), "__kwdefaults__")[Id2String(X)] := O))) ~> makeFunction(N, ((ListItem(X = O) => ListItem(X)) _), _, true)
  rule makeFunction(_, ((ListItem(X) => .) _), _, _)

  //TODO: co_flags and undefinedness (needs hooks)
  rule (. => setattr(N, "co_flags", (getattr(ref(N), "co_flags") |Int 4)) ~> addParam(* X)) ~> makeCodeObject(N, ((ListItem(* X) => ListItem(*)) L), _, false) 
  context setattr(_, _, (getattr(HOLE, _) |Int _:Int))
  rule makeFunction(N, ((ListItem(* X) => ListItem(*)) L), _, _)
  rule makeFunction(_, ((ListItem(*) => .) L), _, (false => true))
  rule makeCodeObject(_, ((ListItem(*) => .) L), _, (false => true))
  rule (. => setattr(N, "co_flags", (getattr(ref(N), "co_flags") |Int 8)) ~> addParam(** X)) ~> makeCodeObject(N, ((ListItem(** X) => .) L), _, _)
  rule makeFunction(N, ((ListItem(** X) => .) L), _, _)
  rule (. => getref(ref(N), "__annotations__")[paramName(Arg)] := O) ~> makeFunction(N, ((ListItem(Arg:K : O) => ListItem(Arg)) _), _, _) 
  rule (. => getref(ref(N), "__annotations__")["return"] := O) ~> makeFunction(N, _, (O => .Obj), _) 
  rule makeCodeObject(N, ((ListItem(Arg : _) => ListItem(Arg)) _), _, _)

  syntax ObjRef ::= "makeClosure" "(" Expression ")" [:strict:]
                  | "cellNum" "(" Expression "," Expression "," Expression ")" [:strict:]

  rule makeFunction(N, ., .Obj, _) => setref(N, "__closure__", makeClosure(ref(N) . String2Id("__code__") . String2Id("co_freevars")))
  rule makeClosure(O) => makeClosure(list(listvalue(O)))
  rule makeClosure(list(.)) => tuple()
  rule <k> makeClosure(list(ListItem(N) L)) => tuple((getref(ref(Frame), "f_cells")[ref(N)]), .Expressions) + makeClosure(list(L)) ...</k>
       <currentFrame> Frame:Nat </currentFrame>

  syntax K ::= "createFunction" "(" Id "," K "," K "," Expression ")" [:strict(4):]
             | "createLambda" "(" K "," Expression ")" [:strict(2):]
             | "makescope" "(" K ")"
             | "storescope"
             | "propscope"
             | "delscope"

  syntax ListItem ::= "(" K "," Set "," Set "," Set "," Set "," Set "," List ")"

  rule <k> makescope (K) => . ...</k>
       <scope> . => (K, .Set, .Set, .Set, .Set, .Set, .List) ...</scope>

  rule <k> visited(_) ~> storescope => . ...</k>
       <scope> (.K, _:Set, _:Set, _:Set, _:Set, _:Set, _:List) ...</scope>

  rule <k> visited(K) ~> storescope => 
           setattr(N, "co_code", K) ~>
           setref(N, "co_freevars", tuple(DeListify(DeSetify(
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) -Set 
             LOCAL(Defs, Globals, Nonlocals, Params))))) ~>
           setref(N, "co_cellvars", tuple(DeListify(DeSetify(
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) &Set
             LOCAL(Defs, Globals, Nonlocals, Params))))) ~>
           setref(N, "co_varnames", tuple(DeListify(PARAMS(Params) DeSetify(
             (LOCAL(Defs, Globals, Nonlocals, Params) -Set
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L)) -Set
             Setify(PARAMS(Params)))))) ~>
           setref(N, "co_names", tuple(DeListify(DeSetify(
             (Uses -Set
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L)) -Set
             LOCAL(Defs, Globals, Nonlocals, Params))))) ...</k>
       <scope> (N, Defs:Set, Uses:Set, Nonlocals:Set, Globals:Set, ChildFree:Set, Params:List) L</scope>

  rule <k> propscope => . ...</k>
       <scope> LI:ListItem </scope>
  rule <k> propscope => . ...</k>
       <scope> (_, Defs, Uses, Nonlocals, Globals, ChildFree, Params) (N, Defs2:Set, Uses2:Set, Nonlocals2:Set, Globals2:Set, ChildFree2:Set (. => (FREE(Defs, Uses, Globals, Nonlocals, ChildFree, (N, Defs2, Uses2, Nonlocals2, Globals2, ChildFree2, Params2) L)) -Set LOCAL(Defs, Globals, Nonlocals, Params)), Params2:List) L </scope>

  rule <k> delscope => . ...</k>
       <scope> LI:ListItem => . ...</scope>

  syntax Set ::= "FREE" "(" Set "," Set "," Set "," Set "," Set "," List ")" [:function:]
  syntax Set ::= "LOCAL" "(" Set "," Set "," Set "," List ")" [:function:]
  syntax Set ::= "BOUND" "(" Set "," Set "," List ")" [:function:]
  syntax List ::= "PARAMS" "(" List ")" [:function:]
  define LOCAL(Defs, Globals, Nonlocals, Params) => ((Defs Setify(PARAMS(Params))) -Set Globals) -Set Nonlocals when Setify(PARAMS(Params)) &Set Nonlocals ==Set . andBool Setify(PARAMS(Params)) &Set Globals ==Set .
  define FREE(_, _, _, Nonlocals, ChildFree, .) => Nonlocals ChildFree
  define FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L (_, Defs2, _, _, _, _, .)) => FREE(Defs, Uses, Globals, Nonlocals, ChildFree, .) (((Uses Defs) &Set BOUND(.,Defs2,L)) -Set Globals)
  define BOUND(Bound:Set, Globals, L (_, Defs, _, Nonlocals, Globals2, _, Params)) => BOUND((Bound LOCAL(Defs, Globals2, Nonlocals, Params)) -Set Globals, (Globals -Set LOCAL(Defs, Globals2, Nonlocals, Params)) Globals2, L)
  define BOUND(Bound, _, .) => Bound
  define PARAMS(ListItem(X) Params) => ListItem(Id2String(X)) PARAMS(Params)
  define PARAMS(ListItem(* X) Params) => PARAMS(Params ListItem(* X))
  define PARAMS(ListItem(** X) ListItem(* Y:Id)) => ListItem(Id2String(Y)) ListItem(Id2String(X))
  define PARAMS(ListItem(* X)) => ListItem(Id2String(X))
  define PARAMS(ListItem(** X)) => ListItem(Id2String(X))
  define PARAMS(ListItem(* X) ListItem(** Y)) => ListItem(Id2String(X)) ListItem(Id2String(Y))
  define PARAMS(.) => .

  rule createFunction(X, Ps, K:K, O) => visited((X, .Expressions) := function(Ps, O, K))
  rule createLambda(Ps, O) => visited(function(Ps, O, .Obj))

  rule makeCodeObject(N, ., Ss, _) => visit(Ss, 'compileVisitor) ~> storescope ~> propscope ~> delscope

  syntax K ::= "compileVisitor" "(" KLabel "," Nat "," K ")" [:klabel(compileVisitor):]
             | "compileReturner" "(" K ")" [:klabel(compileReturner):]
             | "parameterVisitor" "(" KLabel "," Nat "," K ")" [:klabel(parameterVisitor):]
             | "parameterReturner" "(" K ")" [:klabel(parameterReturner):]
             | "bindVisitor" "(" KLabel "," Nat "," K ")" [:klabel(bindVisitor):]
             | "bindReturner" "(" K ")" [:klabel(bindReturner):]
             | "importVisitor" "(" KLabel "," Nat "," K ")" [:klabel(importVisitor):]
             | "importReturner" "(" K ")" [:klabel(importReturner):] 

  syntax K ::= "addDef" "(" Id ")"
             | "addUse" "(" Id ")"
             | "addNonlocals" "(" NAMES ")"
             | "addGlobals" "(" NAMES ")"
             | "addParam" "(" Parameter ")"

  rule <k> addDef(X) => . ...</k>
       <scope> (_, _ (. => SetItem(Id2String(X))), _, _, _, _, _) ...</scope>

  rule <k> addUse(X) => . ...</k>
       <scope> (_, _, _ (. => SetItem(Id2String(X))), _, _, _, _) ...</scope>

  rule <k> addNonlocals(X , Xs => Xs) ...</k>
       <scope> (_, _, _, _ (. => SetItem(Id2String(X))), _, _, _) ...</scope>

  rule <k> addGlobals(X, Xs => Xs) ...</k>
       <scope> (_, _, _, _, _ (. => SetItem(Id2String(X))), _, _) ...</scope>

  rule <k> addParam(K) => . ...</k>
       <scope> (_, _, _, _, _, _, _ (. => ListItem(K))) ...</scope>

  rule addGlobals(.NAMES) => .
  rule addNonlocals(.NAMES) => .

  define returner('compileVisitor) => 'compileReturner
  define returner('parameterVisitor) => 'parameterReturner
  define returner('bindVisitor) => 'bindReturner
  define returner('importVisitor) => 'importReturner

  rule compileVisitor('import_, 0, K) => visit(K, 'importVisitor)
  rule compileVisitor('from_import_, 0, K) => visited(K)
  rule compileVisitor('from_import_, 1, K) => visit(K, 'importVisitor)
  rule importVisitor('_._, 1, K) => visited(K)
  rule importVisitor('_as_, 0, K) => visited(K)
  rule importVisitor(Lbl:KLabel, N, K) => visit(K, 'importVisitor) when notBool((N ==Int 1 andBool Lbl ==KLabel '_._) orBool (N ==Int 0 andBool Lbl ==KLabel '_as_))
  rule importReturner(X) => visit(X, 'bindVisitor)
  rule importReturner(K) => visited(K) when 'isId(K) =/=K true

  rule compileVisitor('def_`(_`):_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('def_`(_`):_, 1, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('def_`(_`):_, 2, Ss) => visited(Ss)
  rule compileReturner(def X (Ps): Ss) => createFunction(X, Ps, .Obj, codeObject(X, Ps, Ss))
  rule compileVisitor('def_`(_`)->_:_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('def_`(_`)->_:_, 1, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('def_`(_`)->_:_, 3, Ss) => visited(Ss)
  rule compileReturner(def X (Ps)-> K : Ss) => createFunction(X, Ps, K, codeObject(X, Ps, Ss))

  rule compileVisitor('lambda_:_, 0, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('lambda_:_, 1, K) => visited(K)
  rule compileReturner(lambda Ps : K) => createLambda(Ps, codeObject(String2Id("<lambda>"), Ps, return K))

  rule parameterVisitor('_=_,1,K) => visit(K, 'compileVisitor)
  rule parameterVisitor('_:_,1,K) => visit(K, 'compileVisitor)
  rule parameterVisitor(Lbl, N, K) => visit(K, 'parameterVisitor) when notBool(N ==Int 1 andBool (Lbl ==KLabel '_=_ orBool Lbl ==KLabel '_:_))
  rule parameterReturner(K) => visited(K)

  rule compileVisitor('class_`(_`):_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('class_`(_`):_, 2, Ss) => visited(Ss)
  rule compileReturner(class X (As:K): Ss) => makescope(.) ~> visit(Ss, 'compileVisitor) ~> propscope ~> delscope

  rule compileVisitor('_:=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_+=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_-=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_*=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_/=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_floor/=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_%=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_**=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_>>=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_<<=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_&=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_^=_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('_|=_,0,K) => visit(K, 'bindVisitor)

  rule compileVisitor('for_in_:_,0,K) => visit(K, 'bindVisitor)
  rule compileVisitor('with_as_:_,1,K) => visit(K, 'bindVisitor)
  rule compileVisitor('except_as_:_,1,K) => visit(K, 'bindVisitor)
  rule compileVisitor('del_,0,K) => visit(K, 'bindVisitor)

  rule compileVisitor('global_,0,Xs:NAMES) => addGlobals(Xs) ~> visited(Xs)
  rule compileVisitor('nonlocal_,0,Xs) => addNonlocals(Xs) ~> visited(Xs)

  rule compileReturner(X) => addUse(X) ~> visited(X)
  rule compileVisitor('_=_, 0, K) => visited(K)

  rule bindVisitor('_._, 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_._, 1, K) => visited(K)
  rule bindVisitor('_`[_`], 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_`[_`], 1, K) => visited(K)
  rule bindVisitor(Lbl, _, K) => visit(K, 'bindVisitor) when notBool(Lbl ==KLabel '_._ orBool Lbl ==KLabel '_`[_`])
  rule bindReturner(X) => addDef(X) ~> visited(X)
  rule bindReturner(K) => visited(K) when 'isId(K) =/=K true

  rule compileVisitor(Lbl, N, K) => visit(K, 'compileVisitor) when notBool ((Lbl ==KLabel 'def_`(_`)->_:_ andBool N =/=Int 2) orElseBool (Lbl ==KLabel 'class_`(_`):_ andBool N =/=Int 1) orElseBool (N ==Int 0 andBool (Lbl ==KLabel '_:=_ orElseBool Lbl ==KLabel '_+=_ orElseBool Lbl ==KLabel '_-=_ orElseBool Lbl ==KLabel '_*=_ orElseBool Lbl ==KLabel '_/=_ orElseBool Lbl ==KLabel '_floor/=_ orElseBool Lbl ==KLabel '_%=_ orElseBool Lbl ==KLabel '_**=_ orElseBool Lbl ==KLabel '_>>=_ orElseBool Lbl ==KLabel '_<<=_ orElseBool Lbl ==KLabel '_&=_ orElseBool Lbl ==KLabel '_^=_ orElseBool Lbl ==KLabel '_|=_)) orElseBool (Lbl ==KLabel 'for_in_:_ andBool N ==Int 0) orElseBool (Lbl ==KLabel 'with_as_:_ andBool N ==Int 1) orElseBool (Lbl ==KLabel 'except_as_:_ andBool N ==Int 1) orElseBool Lbl ==KLabel 'del_ orElseBool Lbl ==KLabel 'global_ orElseBool Lbl ==KLabel 'nonlocal_ orElseBool (Lbl ==KLabel '_=_ andBool N ==Int 0) orElseBool Lbl ==KLabel 'import_ orElseBool Lbl ==KLabel 'from_import_ orElseBool Lbl ==KLabel 'def_`(_`):_ orElseBool Lbl ==KLabel 'lambda_:_)

  rule compileReturner(K) => visited(K) when getKLabel K =/=KLabel 'def_`(_`)->_:_ andBool getKLabel K =/=KLabel 'def_`(_`):_ andBool getKLabel K =/=KLabel 'class_`(_`):_ andBool 'isId(K) =/=K true
  rule compileReturner(.) => visited(.)

end module
