module PYTHON-SEMANTICS-CALLS
  imports PYTHON-SEMANTICS-LITERALS

  syntax K ::= "processArgs" "(" List "," Map "," Expression "," Expression ")" [:strict(3 4):]
             | "sortArgs" "(" List ")"
             | "matchArgs" "(" Expression "," List "," Map "," Map "," #Nat ")" [:strict(1):]
             | "addArg" "(" #String "," Expression ")" [:strict(2):]

  rule <k> obj(S,ObjState:Bag) (Args:K) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeBuiltin(obj(S,ObjState), ., .) ...</k> when 'isKResult(Args)
  rule <k> invokeBuiltin(obj("call_function",_), ListItem(O:Object) L:List, M:Map) => invokeFunction(O, L, M) ...</k>
  rule <k> invokeFunction(O, L, M) => matchArgs(O, L, M, ., 0) ...</k>

  define 'isKResult(_ = K) => true when 'isKResult(K)

  rule sortArgs((ListItem(O) => .) _) ~> processArgs(_ (. => ListItem(O)),.,_,_)
  rule sortArgs((ListItem(X:#Id = O) => .) _) ~> processArgs(_,M (. => Id2String(X) |-> O),_,_) when notBool(Id2String(X) in keys(M))
  rule sortArgs((ListItem(* O) => .) _) ~> processArgs(_,_,(_ => O),_)
  rule sortArgs((ListItem(** O) => .) _) ~> processArgs(_,_,_,(_ => O))
  rule sortArgs(.) => .

  rule <k> (. => iterate(O, raiseInternal("TypeError", "argument after * must be a sequence"))) ~> processArgs(_,_,O,_) ...</k>
  rule <k> (list(L:List) => .) ~> processArgs(_ (. => L),_,(_:Object => .Obj),_) ...</k>
  rule <k> (. => mapping(O, raiseInternal("TypeError", "argument after ** must be a mapping"))) ~> processArgs(_,_,.Obj,O) ...</k>
  rule <k> (. => test(istype(O, ref("str")), ., raiseInternal("TypeError", "keywords must be strings"))) ~> map(_ (O |-> O2:Object => .)) ~> processArgs(_,_ (. => strvalue(O) |-> O2),.Obj,_) ...</k>
  rule <k> (map(.) => .) ~> processArgs(_,_,.Obj,(_:Object => .Obj)) ...</k>

  rule <k> (processArgs(L, M:Map, .Obj, .Obj) => .) ~> invokeBuiltin(_, (. => L), (. => M)) ...</k>

  //process positional arguments
  rule <k> matchArgs(obj(_,<oattrs>... "co_argnames" |-> list((ListItem(S:#String) => .) _) ...</oattrs>),(ListItem(O) => .) _, _, _ (. => #id S |-> id(O)),(N => sNat(N))) ...</k>

  //leftover positional arguments get stored in vararg
  rule <k> (. => addArg(S, immutable(list(Idify(L)), ref("tuple")))) ~> matchArgs(obj(_,<oattrs>... "co_argnames" |-> list(.) ("co_varargname" |-> S => .) ...</oattrs>), (L => .), _, _, _) ...</k>

  rule <k> (addArg(S, O) => .) ~> matchArgs(_,_,_,_ (. => #id S |-> id(O)), _) ...</k>

  // if there is no vararg, leftover positional arguments raise TypeError
  rule <k> matchArgs(obj(_,<oattrs> "co_argnames" |-> list(.) "co_argcount" |-> N:#Nat "__defaults__" |-> map(M2:Map) "__name__" |-> S M </oattrs>), ListItem(_) L, _, _, N2:#Nat) => raiseInternal("TypeError", S +String "() takes " +String Int2String(N -Int lengthMap M2) +String " to at most " +String Int2String(N) +String " positional arguments (" +String Int2String(N2) +String " given)") ...</k> when notBool ("co_varargname" in keys(M))

  // keyword arguments fill positional and kwonly arguments
  rule <k> matchArgs(obj(_,<oattrs>... "co_argnames" |-> list(_ (ListItem(S) => .) _) ...</oattrs>),.,_ (S |-> O => .),M (. => #id S |-> id(O)),(N => sNat(N))) ...</k> when notBool(#id S in keys(M))
  rule <k> matchArgs(obj(_,<oattrs>... "co_kwonlyargnames" |-> list(_ (ListItem(S) => .) _) ...</oattrs>),.,_ (S |-> O => .),M (. => #id S |-> id(O)),_) ...</k> when notBool(#id S in keys(M))
 
  // cannot specify a parameter both positionally and as a keyword
  rule <k> matchArgs(obj(_,<oattrs>... "__name__" |-> S2:#String ...</oattrs>),.,_ S |-> _,_ #id S |-> _,_) => raiseInternal("TypeError", S2 +String "() got multiple values for keyword argument '" +String S +String "'") ...</k>

  // fill in default value for unspecified parameter
  rule <k> matchArgs(obj(_,<oattrs>... S2 |-> list((ListItem(S) => .) _) S3:#String |-> map(_ S |-> B _) ...</oattrs>),.,M,_ (. => #id S |-> B),_) ...</k> when notBool(S in keys(M)) andBool ((S2 ==Bool "co_argnames" andBool S3 ==Bool "__defaults__") orBool (S2 ==Bool "co_kwonlyargnames" andBool S3 ==Bool "__kwdefaults__"))
/*
  // raise TypeError if an unspecified positional argument doesn't have a default
  rule <k> matchArgs(obj(_,<oattrs>... "co_argnames" |-> list(ListItem(S) _) "__defaults__" |-> map(M) "__name__" |-> S2 "co_argcount" |-> N ...</oattrs>),.,M2,_,N2) => raiseInternal("TypeError", S2 +String "() takes at least " +String Int2String(N -Int lengthMap M) +String " to " +String Int2String(N) +String " positional arguments (" +String Int2String(N2) +String " given)") ...</k> when notBool (S in keys(M) orBool S in keys(M2))
*/
  // raise TypeError if an unspecified keyword-only argument doesn't have a default
  rule <k> matchArgs(obj(_,<oattrs>... "co_kwonlyargnames" |-> list(_ ListItem(S) _) "__kwdefaults__" |-> map(M) "__name__" |-> S2 ...</oattrs>),_,M2,_,_) => raiseInternal("TypeError", S2 +String "() needs keyword-only argument " +String S) ...</k> when notBool(S in keys(M) orBool S in keys(M2))

  // raise TypeError if there is no kwarg and there are leftover keyword arguments
  rule <k> matchArgs(obj(_,<oattrs> "co_kwonlyargnames" |-> list(L) "co_argnames" |-> list(L2:List) "__name__" |-> S2 M</oattrs>),_,S |-> _ _,M2,_) => raiseInternal("TypeError", S2 +String "() got an unexpected keyword argument '" +String S +String "'") ...</k> when notBool(S in Setify(L) orBool S in Setify(L2) orBool S in keys(M2) orBool "co_kwargname" in keys(M))

  // leftover keyword arguments get stored in kwarg
  rule <k> (. => addArg(S, { DeMapify(M) })) ~> matchArgs(obj(_,<oattrs>... "co_kwargname" |-> S ("co_kwonlyargnames" |-> list(.) => .) "co_argnames" |-> list(.) ...</oattrs>),.,(M => .),M2,_) ...</k> when keys(M) -Set Ids2Strings(keys(M2)) ==Bool keys(M)

  rule <k> matchArgs(obj(B:Builtin,_),.,.,M,_) => invoke(ref(B), M) ...</k>

  syntax ListItem ::= "(" K "," Bag "," #Nat "," List ")"
  syntax ObjRef ::= "makeLocals" "(" Expression "," Expression "," Map ")" [:strict(1 2):]
                  | "makeLocals" "(" List "," List "," Map "," Expression ")" [:strict(4):]
                  | "makeCells" "(" Expression "," Expression "," Expression "," #Nat ")" [:strict(1 2 3):]
                  | "makeCells" "(" List "," List "," List "," Expression "," #Nat ")" [:strict(4):]

  rule <k> invoke(obj(_:#Nat,<oattrs>... "__closure__" |-> Closure:#Nat "__code__" |-> Code:#Nat "__globals__" |-> Globals:#Nat ...</oattrs>), M) ~> K:K => executeFrame(N, ref(Code), ref(N2), makeLocals(ref(Code) . #id "co_freevars", ref(Closure), M), ref(Globals), ref(Globals) ["__builtins__"], makeCells(ref(Code) . #id "co_freevars", ref(Code) . #id "co_cellvars", ref(Closure), N)) ~> return </k>
       <nextLoc> N => sNat(N) </nextLoc>
       <control>
         <currentFrame> N2 => N </currentFrame>
         <fstack> . => (K, C, N2, LL) ...</fstack>
         <lstack> LL => . </lstack>
         C:Bag
       </control>

  rule makeLocals(Free:Object, O, M) => makeLocals(listvalue(Free), listvalue(O), M, {})
  rule (. => test(getattr(ref(N2), "cell_contents") ==Bool .Obj, ., O[ref(N)] := ref(N2) . #id "cell_contents")) ~> makeLocals((ListItem(N) => .) _, (ListItem(N2) => .) _, M, O)
  rule (. => O[Id2String(X)] := ref(B)) ~> makeLocals(_, _, (X |-> B => .) _, O)
  rule makeLocals(., ., ., O) => ref(id(O))

  rule makeCells(Free, Cells:Object, O, N) => makeCells(listvalue(Free), listvalue(Cells), listvalue(O), {}, N)
  rule (. => O[ref(N)] := ref(N2)) ~> makeCells((ListItem(N) => .) _, _, (ListItem(N2) => .) _, O, _)
  rule <k> (. => O[ref(N)] := ref(N2)) ~> makeCells(_, ListItem(N) _, _, O, Frame:#Nat) ...</k>
       <nextLoc> N2 => sNat(N2) </nextLoc>
       (. => <object>...
         <id>N2</id>
         <oattrs> "__class__" |-> Cell "cell_contents" |-> .Obj "cell_frame" |-> Frame </oattrs>
       ...</object>)
       <symbols>... "cell" |-> Cell:#Nat ...</symbols>

  rule makeCells(.List, .List, .List, O, _) => ref(id(O))

  rule <k> return O ~> _ => O ~> K </k>
       <control>
         <currentFrame> _ => N </currentFrame>
         <fstack> (K, C, N, LL) => . ...</fstack>
         <lstack> _ => LL </lstack>
         (_ => C)
       </control>

  rule <k> (. => Finally:K) ~> return O ...</k>
       <control>
         <fstack> (Finally, C, XL:List, LL:List, _, Ex:K) => . ...</fstack>
         <xstack> _ => XL </xstack>
         <xcontext> _ => Ex </xcontext>
         <lstack> _ => LL </lstack>
         (_ => C)
       </control>

end module
