module PYTHON-SEMANTICS-FUNCTIONS
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "addParams" "(" List "," #Nat "," #Bool ")"
             | "enclose" "(" #Nat "," #Nat ")"
  syntax #String ::= "paramName" "(" Argument ")"

  rule paramName(X) => Id2String(X)
  rule paramName(X = _) => Id2String(X)
  rule paramName(* X) => Id2String(X)
  rule paramName(** X) => Id2String(X)

  syntax ObjRef ::= "function" "(" #Id "," Parameters "," Statements "," #Bool "," Map "," Expression ")" [:strict(6):]

  rule <k> def X:#Id ( Ps:Parameters ) : Ss:K => function(X, Ps, Ss, true, ., ref("function")) ; ...</k>
  rule <k> def X ( Ps ) -> obj(B:Builtin, _) : Ss => function(X, Ps, Ss, true, "return" |-> B, ref("function")) ; ...</k>
  rule <k> lambda Ps : E:Expression => function(#id "<lambda>", Ps, return E, false, ., ref("function")) ...</k> 

  rule <k> function(X, Ps, Ss, T:#Bool, Rho:Map, O:Object) => (addParams(Listify(Ps), N, false) ~> enclose(N, N2) ~> test(T, bind(X, N), .) ~> ref(N)) ...</k>
       <nextLoc> N:#Nat => N +Int 1 </nextLoc>
       <currentBlock> N2:#Nat </currentBlock>
       (. => <object>...
         <id>N</id>
         <oattrs> "__annotations__" |-> map(Rho) "__code__" |-> Ss "__defaults__" |-> map(.) "__kwdefaults__" |-> map(.) "__name__" |-> Id2String(X) "co_argcount" |-> 0 "co_argnames" |-> list(.) "co_kwonlyargcount" |-> 0 "co_kwonlyargnames" |-> list(.) "__class__" |-> id(O) </oattrs>
       ...</object>)

  context addParams((ListItem(X = HOLE) _:List), _, _)
  context addParams((_:List ListItem(X : HOLE) _:List), _, _)
  context addParams((ListItem((X = HOLE) : _) _:List), _, _)
  context addParams((_:List ListItem((X = _) : HOLE) _:List), _, _)
  context addParams((_:List ListItem((*_(_)) : HOLE) _:List), _, _)
  context addParams((_:List ListItem((** _) : HOLE) _:List), _, _)

  rule <k> addParams(., _, _) => . ...</k>
  rule <k> enclose(N, N2) => . ...</k>
       <blockId> N2 </blockId>
       <isClass> false </isClass>
       <object>...
         <id>N</id>
         <oattrs>... . => "__closure__" |-> N2 ...</oattrs>
       ...</object>

  rule <k> enclose(N, (N2 => N3)) ...</k>
       <blockId> N2 </blockId>
       <parentBlock> N3:#Nat </parentBlock>
       <isClass> true </isClass>

  rule <k> addParams((ListItem(X) L:List), N, false) => addParams(L, N, false) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_argcount" |-> (N2 => N2 +Int 1) "co_argnames" |-> list(_ (. => ListItem(Id2String(X)))) ...</oattrs>
       ...</object>

  rule <k> addParams((ListItem(X) L), N, true) => addParams(L, N, true) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "co_kwonlyargcount" |-> (N2 => N2 +Int 1) "co_kwonlyargnames" |-> list(_ (. => ListItem(Id2String(X)))) ...</oattrs>
       ...</object>

  rule <k> addParams((ListItem(X = obj(B,_)) L), N, false) => addParams((ListItem(X) L), N, false) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "__defaults__" |-> map(_ (. => Id2String(X) |-> B)) ...</oattrs>
       ...</object>

  rule <k> addParams((ListItem(X = obj(B,_)) L), N, true) => addParams((ListItem(X) L), N, true) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "__kwdefaults__" |-> map(_ (. => Id2String(X) |-> B)) ...</oattrs>
       ...</object>

  rule <k> addParams((ListItem(* X) L), N, T) => addParams((ListItem(*) L), N, T) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "co_varargname" |-> Id2String(X) ...</oattrs>
       ...</object>

  rule <k> addParams((ListItem(*) L), N, false) => addParams(L, N, true) ...</k>

  rule <k> addParams((ListItem(** X) L), N, T:#Bool) => addParams(L, N, T) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "co_kwargname" |-> Id2String(X) ...</oattrs>
       ...</object>

  rule <k> addParams((ListItem(Arg:Argument : obj(B,_)) L), N, T) => addParams((ListItem(Arg) L), N, T) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "__annotations__" |-> map(Rho => Rho[B / paramName(Arg)]) ...</oattrs>
       ...</object>

end module
