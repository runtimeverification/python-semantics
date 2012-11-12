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
  rule paramName(* X) => Id2String(X)
  rule paramName(** X) => Id2String(X)

  syntax ObjRef ::= "function" "(" Parameters "," Expression "," K ")" [strict(2)]

  rule <k> function(Ps:K, O:Object, Return:K) =>
           setref(N, "__doc__", (O . String2Id("co_consts") [0])) ~> 
           setref(N, "__name__", O . String2Id("co_name")) ~> 
           setref(N, "__module__", (ref("globals")(.Arguments)["__name__"])) ~> 
           setref(N, "__defaults__", ref("None")) ~>
           setref(N, "__globals__", (ref("globals")(.Arguments))) ~> 
           setref(N, "__dict__", {.KeyData}) ~> 
           setref(N, "__closure__", ref("None")) ~>
           setref(N, "__annotations__", {.KeyData}) ~> 
           setref(N, "__kwdefaults__", ref("None")) ~>
           setattr(N, "__frame__", N2) ~>
           makeFunction(N, Listify(Ps), Return, false) ~> ref(N) ...</k>
       <nextLoc> N:Int => N +Int 1 </nextLoc>
       <currentFrame> N2 </currentFrame>
       (. => <object>
         <id>N</id>
         <oattrs> "__code__" |-> ref(id(O)) "__class__" |-> ref("function") </oattrs>
       </object>)

  rule <k> codeObject(X, Ps, Ss:K, T:Bool) =>
           setref(N, "co_varnames", tuple(.Expressions)) ~>
           setref(N, "co_consts", tuple(docString(Ss))) ~>
           makescope(N, T) ~>
           makeCodeObject(N, Listify(Ps), Ss, false) ~> ref(N) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "co_name" |-> Id2String(X) "co_argcount" |-> 0 "co_kwonlyargcount" |-> 0 "co_nlocals" |-> 0 "__class__" |-> ref("code") "co_flags" |-> 0 </oattrs>
       ...</object>)
       

  context makeFunction(_, (ListItem(X = HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem(X : HOLE) _:List), _, _)
  context makeFunction(_, (ListItem((X = HOLE) : _) _:List), _, _)
  context makeFunction(_, (_:List ListItem((X = _) : HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem((* _) : HOLE) _:List), _, _)
  context makeFunction(_, (_:List ListItem((** _) : HOLE) _:List), _, _) 
  context makeFunction(_, _, HOLE, _)

  rule <k> (. => addParam(X)) ~> makeCodeObject(N, (ListItem(X) L:List => L), _, false) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_argcount" |-> (N2:Int => N2 +Int 1) "co_nlocals" |-> (N3:Int => N3 +Int 1) ...</oattrs>
       ...</object>

  rule <k> (. => addParam(X)) ~> makeCodeObject(N, (ListItem(X) L:List => L), _, true) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_nlocals" |-> (N2 => N2 +Int 1) "co_kwonlyargcount" |-> (N3 => N3 +Int 1) ...</oattrs>
       ...</object>

  rule makeCodeObject(_, ((ListItem(X = _) => ListItem(X)) _), _, _)

  rule (. => setref(N, "__defaults__", test(plbool(getref2(ref(N), "__defaults__") is ref("None")), tuple(O), (getref2(ref(N), "__defaults__") + tuple(O))))) ~> makeFunction(N, ((ListItem(X:Id = O:Object) => ListItem(X)) _), _, false)
  rule (. => test(plbool(getref2(ref(N), "__kwdefaults__") is ref("None")), setref(N, "__kwdefaults__", {Id2String(X) : O}), (getref2(ref(N), "__kwdefaults__")[Id2String(X)] := O))) ~> makeFunction(N, ((ListItem(X:Id = O:Object) => ListItem(X)) _), _, true)
  rule makeFunction(_, ((ListItem(X:Id) => .) _), _, _)

  rule (. => setattr(N, "co_flags", (getattr(ref(N), "co_flags") |Int 4)) ~> addParam(* X)) ~> makeCodeObject(N, ((ListItem(* X:Id) => ListItem(*)) L), _, false) 
  context setattr(_, _, (getattr(HOLE, _) |Int _:Int))
  rule makeFunction(N, ((ListItem(* X:Id) => ListItem(*)) L), _, _)
  rule makeFunction(_, ((ListItem(*) => .) L), _, (false => true))
  rule makeCodeObject(_, ((ListItem(*) => .) L), _, (false => true))
  rule (. => setattr(N, "co_flags", (getattr(ref(N), "co_flags") |Int 8)) ~> addParam(** X)) ~> makeCodeObject(N, ((ListItem(** X:Id) => .) L), _, _)
  rule makeFunction(N, ((ListItem(** X) => .) L), _, _)
  rule (. => getref2(ref(N), "__annotations__")[paramName(Arg)] := O) ~> makeFunction(N, ((ListItem(Arg:K : O:Object) => ListItem(Arg)) _), _, _) 
  rule (. => getref2(ref(N), "__annotations__")["return"] := O) ~> makeFunction(N, _, (O:Object => .Obj), _) 
  rule makeCodeObject(N, ((ListItem(Arg : _) => ListItem(Arg)) _), _, _)

  syntax ObjRef ::= "makeClosure" "(" Expression ")" [strict]
                  | "cellNum" "(" Expression "," Expression "," Expression ")" [strict]

  rule makeFunction(N, ., .Obj, _) => setref(N, "__closure__", makeClosure(ref(N) . String2Id("__code__") . String2Id("co_freevars")))
  rule makeClosure(O:Object) => makeClosure(list(listvalue(O)))
  rule makeClosure(list(.)) => tuple(.Expressions)
  rule <k> makeClosure(list(ListItem(N) L)) => tuple((getref2(ref(Frame), "f_cells")[N]), .Expressions) + makeClosure(list(L)) ...</k>
       <currentFrame> Frame:Int </currentFrame>

  syntax K ::= "createFunction" "(" Id "," K "," K "," Expression ")" [strict(4)]
             | "createLambda" "(" K "," Expression ")" [strict(2)]
             | "createClass" "(" Id "," K "," Expression ")" [strict(3)]
             | "makescope" "(" K "," Bool ")"
             | "storescope"
             | "propscope"
             | "delscope"

  syntax ListItem ::= "(" K "," Set "," Set "," Set "," Set "," Set "," List "," Bool ")"

  rule <k> makescope (K, T:Bool) => . ...</k>
       <scope> . => (K, .Set, .Set, .Set, .Set, .Set, .List, T) ...</scope>

  rule <k> visited(_) ~> storescope => . ...</k>
       <scope> (.K, _:Set, _:Set, _:Set, _:Set, _:Set, _:List, _) ...</scope>

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
             ((Uses Globals) -Set
             FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L)) -Set
             LOCAL(Defs, Globals, Nonlocals, Params))))) ...</k>
       <scope> (N, Defs:Set, Uses:Set, Nonlocals:Set, Globals:Set, ChildFree:Set, Params:List, _) L</scope>

  rule <k> propscope => . ...</k>
       <scope> LI:ListItem </scope>
  rule <k> propscope => . ...</k>
       <scope> (_, Defs, Uses, Nonlocals, Globals, ChildFree, Params, _) (N, Defs2:Set, Uses2:Set, Nonlocals2:Set, Globals2:Set, ChildFree2:Set (. => (FREE(Defs, Uses, Globals, Nonlocals, ChildFree, (N, Defs2, Uses2, Nonlocals2, Globals2, ChildFree2, Params2, T) L)) -Set LOCAL(Defs, Globals, Nonlocals, Params)), Params2:List, T) L </scope>

  rule <k> delscope => . ...</k>
       <scope> LI:ListItem => . ...</scope>

  syntax Set ::= "FREE" "(" Set "," Set "," Set "," Set "," Set "," List ")" [function]
  syntax Set ::= "LOCAL" "(" Set "," Set "," Set "," List ")" [function]
  syntax Set ::= "BOUND" "(" Set "," List ")" [function]
  syntax List ::= "PARAMS" "(" List ")" [function]
  rule LOCAL(Defs, Globals, Nonlocals, Params) => ((Defs Setify(PARAMS(Params))) -Set Globals) -Set Nonlocals when Setify(PARAMS(Params)) &Set Nonlocals ==Set . andBool Setify(PARAMS(Params)) &Set Globals ==Set . [function, anywhere]
  rule FREE(Defs, Uses, Globals, Nonlocals, ChildFree, L) => Nonlocals ChildFree (((Uses Defs) &Set BOUND(.,L)) -Set Globals) when (Nonlocals &Set BOUND(., L)) ==Set Nonlocals [function, anywhere]
  rule BOUND(Bound:Set, L (_, Defs, _, Nonlocals, Globals2, _, Params, false)) => BOUND((Bound LOCAL(Defs, Globals2, Nonlocals, Params)) -Set Globals2, L) [function, anywhere]
  rule BOUND(Bound:Set, L (_, _:Set, _:Set, _:Set, _:Set, _:Set, _:List, true)) => BOUND(Bound, L)
  rule BOUND(Bound, .) => Bound [function, anywhere]
  rule PARAMS(ListItem(X:Id) Params) => ListItem(Id2String(X)) PARAMS(Params) [function, anywhere]
  rule PARAMS(ListItem(* X:Id) Params) => PARAMS(Params ListItem(* X)) [function, anywhere]
  rule PARAMS(ListItem(** X:Id) ListItem(* Y:Id)) => ListItem(Id2String(Y)) ListItem(Id2String(X)) [function, anywhere]
  rule PARAMS(ListItem(* X:Id)) => ListItem(Id2String(X)) [function, anywhere]
  rule PARAMS(ListItem(** X:Id)) => ListItem(Id2String(X)) [function, anywhere]
  rule PARAMS(ListItem(* X:Id) ListItem(** Y:Id)) => ListItem(Id2String(X)) ListItem(Id2String(Y)) [function, anywhere]
  rule PARAMS(.) => . [function, anywhere]

  rule createFunction(X, Ps, K:K, O:Object) => visited((X, .Expressions) := function(Ps, O, K))
  rule createLambda(Ps, O:Object) => visited(function(Ps, O, .Obj))
  rule createClass(X, As, O:Object) => visited((X, .Expressions) := class(As, O))

  rule makeCodeObject(N, ., Ss, _) => visit(Ss, 'compileVisitor) ~> storescope ~> propscope ~> delscope

  syntax K ::= "compileVisitor" "(" KLabel "," Int "," K ")" [klabel('compileVisitor)]
             | "parameterVisitor" "(" KLabel "," Int "," K ")" [klabel('parameterVisitor)]
             | "bindVisitor" "(" KLabel "," Int "," K ")" [klabel('bindVisitor)]
             | "importVisitor" "(" KLabel "," Int "," K ")" [klabel('importVisitor)]

  syntax K ::= "addDef" "(" Id ")"
             | "addUse" "(" Id ")"
             | "addNonlocals" "(" NAMES ")"
             | "addGlobals" "(" NAMES ")"
             | "addParam" "(" Parameter ")"

  rule <k> addDef(X) => . ...</k>
       <scope> (_, _ (. => SetItem(Id2String(X))), _, _, _, _, _, _) ...</scope>

  rule <k> addUse(X) => . ...</k>
       <scope> (_, _, _ (. => SetItem(Id2String(X))), _, _, _, _, _) ...</scope>

  rule <k> addNonlocals(X , Xs => Xs) ...</k>
       <scope> (_, _, _, _ (. => SetItem(Id2String(X))), _, _, _, _) ...</scope>

  rule <k> addGlobals(X, Xs => Xs) ...</k>
       <scope> (_, _, _, _, _ (. => SetItem(Id2String(X))), _, _, _) ...</scope>

  rule <k> addParam(K) => . ...</k>
       <scope> (_, _:Set, _:Set, _:Set, _:Set, _:Set, _ (. => ListItem(K)), _) ...</scope>

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
  rule compileVisitor(returner, -1, (def X (Ps): Ss)) => createFunction(X, Ps, .Obj, codeObject(X, Ps, Ss, false))
  rule compileVisitor('def_`(_`)->_:_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('def_`(_`)->_:_, 1, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('def_`(_`)->_:_, 3, Ss) => visited(Ss)
  rule compileVisitor(returner, -1, (def X (Ps)-> K : Ss)) => createFunction(X, Ps, K, codeObject(X, Ps, Ss, false))

  rule compileVisitor('lambda_:_, 0, Ps) => visit(Ps, 'parameterVisitor)
  rule compileVisitor('lambda_:_, 1, K) => visited(K)
  rule compileVisitor(returner, -1, (lambda Ps : K)) => createLambda(Ps, codeObject(String2Id("<lambda>"), Ps, return K, false))

  rule parameterVisitor('_=_,1,K) => visit(K, 'compileVisitor)
  rule parameterVisitor('_:_,1,K) => visit(K, 'compileVisitor)
  rule parameterVisitor(Lbl, N, K) => visit(K, 'parameterVisitor) when notBool(N ==Int 1 andBool (Lbl ==KLabel '_=_ orBool Lbl ==KLabel '_:_)) andBool N =/=Int -1
  rule parameterVisitor(returner, -1, K) => visited(K)

  rule compileVisitor('class_`(_`):_, 0, X) => visit(X, 'bindVisitor)
  rule compileVisitor('class_`(_`):_, 2, Ss) => visited(Ss)
  rule compileVisitor(returner, -1, (class X (As:K): Ss)) => createClass(X, As, codeObject(X, .Parameters, Ss, true))

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
  rule compileVisitor('nonlocal_,0,Xs:NAMES) => addNonlocals(Xs) ~> visited(Xs)

  rule compileVisitor(returner, -1, X:Id) => addUse(X) ~> visited(X)
  rule compileVisitor('_=_, 0, K) => visited(K)

  rule bindVisitor('_._, 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_._, 1, K) => visited(K)
  rule bindVisitor('_`[_`], 0, K) => visit(K, 'compileVisitor)
  rule bindVisitor('_`[_`], 1, K) => visited(K)
  rule bindVisitor(Lbl, N, K) => visit(K, 'bindVisitor) when notBool(Lbl ==KLabel '_._ orBool Lbl ==KLabel '_`[_`]) andBool N =/=Int -1
  rule bindVisitor(returner, -1, X:Id) => addDef(X) ~> visited(X)
  rule bindVisitor(returner, -1, K) => visited(K) when isId(K) =/=K true

  rule compileVisitor(Lbl, N, K) => visit(K, 'compileVisitor) when notBool ((Lbl ==KLabel 'def_`(_`)->_:_ andBool N =/=Int 2) orElseBool (Lbl ==KLabel 'class_`(_`):_ andBool N =/=Int 1) orElseBool (N ==Int 0 andBool (Lbl ==KLabel '_:=_ orElseBool Lbl ==KLabel '_+=_ orElseBool Lbl ==KLabel '_-=_ orElseBool Lbl ==KLabel '_*=_ orElseBool Lbl ==KLabel '_/=_ orElseBool Lbl ==KLabel '_floor/=_ orElseBool Lbl ==KLabel '_%=_ orElseBool Lbl ==KLabel '_**=_ orElseBool Lbl ==KLabel '_>>=_ orElseBool Lbl ==KLabel '_<<=_ orElseBool Lbl ==KLabel '_&=_ orElseBool Lbl ==KLabel '_^=_ orElseBool Lbl ==KLabel '_|=_)) orElseBool (Lbl ==KLabel 'for_in_:_ andBool N ==Int 0) orElseBool (Lbl ==KLabel 'with_as_:_ andBool N ==Int 1) orElseBool (Lbl ==KLabel 'except_as_:_ andBool N ==Int 1) orElseBool Lbl ==KLabel 'del_ orElseBool Lbl ==KLabel 'global_ orElseBool Lbl ==KLabel 'nonlocal_ orElseBool (Lbl ==KLabel '_=_ andBool N ==Int 0) orElseBool Lbl ==KLabel 'import_ orElseBool Lbl ==KLabel 'from_import_ orElseBool Lbl ==KLabel 'def_`(_`):_ orElseBool Lbl ==KLabel 'lambda_:_) andBool N =/=Int -1

  rule compileVisitor(returner, -1, K) => visited(K) when getKLabel K =/=KLabel 'def_`(_`)->_:_ andBool getKLabel K =/=KLabel 'def_`(_`):_ andBool getKLabel K =/=KLabel 'class_`(_`):_ andBool isId(K) =/=K true
  rule compileVisitor(returner, -1, .) => visited(.)

endmodule
