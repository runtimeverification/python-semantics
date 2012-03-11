module PYTHON-SEMANTICS-CALLS
  imports PYTHON-SEMANTICS-LITERALS

  syntax K ::= "processArgs" "(" List "," Map "," Expression "," Expression ")" [:strict(3 4):]
             | "sortArgs" "(" List ")"
             | "matchArgs" "(" Expression "," List "," Map "," Map "," #Nat ")" [:strict(1):]
             | "addArg" "(" #String "," Expression ")" [:strict(2):]

  rule <k> obj(S,ObjState:Bag) (Args:K) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeBuiltin(obj(S,ObjState), ., .) ...</k> when isKResult(Args)
  rule <k> invokeBuiltin(obj("call_function",_), ListItem(O:Object) L:List, M:Map) => invokeFunction(O, L, M) ...</k>
  rule <k> invokeFunction(O, L, M) => matchArgs(O, L, M, ., 0) ...</k>

  define isKResult(_ = K) => true when isKResult(K)

  rule sortArgs((ListItem(O) => .) _) ~> processArgs(_ (. => ListItem(O)),_,_,_)
  rule sortArgs((ListItem(X:#Id = O) => .) _) ~> processArgs(_,_ (. => Id2String(X) |-> O),_,_)
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
 
  //TODO: SyntaxError for repeated keyword argument
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
  syntax K ::= "bindArgs" "(" Map ")"
             | "bindLocal" "(" #Id "," #Nat ")"
             | "bindLocals" "(" K "," #Bool ")"
             | "bindGlobal" "(" K ")"
             | "bindNonlocal" "(" K ")"

  rule <k> invoke(obj(_:#Nat,<oattrs>... "__closure__" |-> N "__code__" |-> Ss:K ...</oattrs>), M) ~> K:K => bindLocals(Ss, false) ~> bindLocals(Ss, true) ~> bindArgs(M) ~> Ss ~> return </k>
       <nextLoc> N3:#Nat => N3 +Int 1 </nextLoc>
       <control>
         <currentBlock> N2 => N3 </currentBlock>
         <fstack> . => (K, C, N2, LL) ...</fstack>
         <lstack> LL => . </lstack>
         C:Bag
       </control>
       (. => <block>...
         <blockId> N3 </blockId>
         <parentBlock> N </parentBlock>
       ...</block>)

  rule <k> return O ~> _ => O ~> K ...</k>
       <control>
         <currentBlock> _ => N </currentBlock>
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

  rule (. => bind(X,B)) ~> bindArgs((X |-> B => .) _)
  rule bindArgs(.) => .

  rule bindLocals(Stmt:K newline Ss:K, T:#Bool) => bindLocals(Stmt, T) ~> bindLocals(Ss, T)
  rule bindLocals(., _) => .
  rule bindLocals(import X, T) => if T then bindLocal(X,0) else . fi
  rule bindLocals(import X . _, T) => if T then bindLocal(X,0) else . fi
  rule bindLocals(import _ as X, T) => if T then bindLocal(X,0) else . fi
  rule bindLocals(from _ import K, T) => if T then bindLocals(import K, T) else . fi
  rule bindLocals(class X (_) : _, T) => if T then bindLocal(X,0) else . fi
  rule bindLocals(def X (_) -> _ : _, T) => if T then bindLocal(X,0) else . fi
  rule bindLocals(def X (_) : _, T) => if T then bindLocal(X,0) else . fi
  rule bindLocals(K := _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(for K in _ : Ss else: Ss2:K, T) => if T then bindLocals(K, T) else . fi ~> bindLocals(Ss, T) ~> bindLocals(Ss2, T)
  rule bindLocals(with _ as K : Ss, T) => if T then bindLocals(K, T) else . fi ~> bindLocals(Ss, T)
  rule bindLocals(try: Ss ECs:K else: Ss2, T) => bindLocals(Ss, T) ~> bindLocals(ECs, T) ~> bindLocals(Ss2, T)
  rule bindLocals(EC:K except ECs, T) => bindLocals(EC, T) ~> bindLocals(ECs, T)
  rule bindLocals(.ExceptClauses, _) => .
  rule bindLocals(except: Ss, T) => bindLocals(Ss, T)
  rule bindLocals(except _ : Ss, T) => bindLocals(Ss, T)
  rule bindLocals(except _ as K : Ss, T) => if T then bindLocals(K, T) else . fi ~> bindLocals(Ss, T)

  rule bindLocals(try: Ss finally: Ss2, T) => bindLocals(Ss, T) ~> bindLocals(Ss2, T)
  rule bindLocals(while _ : Ss else: Ss2, T) => bindLocals(Ss, T) ~> bindLocals(Ss2, T)
  rule bindLocals(if _ : Ss else: Ss2, T) => bindLocals(Ss, T) ~> bindLocals(Ss2, T)
  rule bindLocals(_ ;, _) => .
  rule bindLocals(K += _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K -= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K *= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K /= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K floor/= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K %= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K **= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K >>= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K <<= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K &= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K ^= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(K |= _, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(del K, T) => if T then bindLocals(K, T) else . fi
  rule bindLocals(return, _) => .
  rule bindLocals(return _, _) => .
  rule bindLocals(raise, _) => .
  rule bindLocals(raise _, _) => .
  rule bindLocals(raise _ from _, _) => .
  rule bindLocals(break, _) => .
  rule bindLocals(continue, _) => .
  rule bindLocals(global Xs:NAMES, T) => if T then . else bindGlobal(Xs) fi
  rule bindLocals(nonlocal Xs, T) => if T then . else bindNonlocal(Xs) fi

  rule bindLocals((K , K2:K), T) => bindLocals(K, T) ~> bindLocals(K2, T)
  rule bindLocals(.Expressions, _) => .
  rule bindLocals(tuple(K), T) => bindLocals(K, T)
  rule bindLocals([ K ], T) => bindLocals(K, T)
  rule bindLocals(_ . _, _) => .
  rule bindLocals(_ [ _ ], _) => .
  rule bindLocals(_ [' _ '], _) => .
  rule bindLocals(* K, T) => bindLocals(K, T)
  rule bindLocals(X, _) => bindLocal(X,0)

  rule bindGlobal(X, Xs) => bindGlobal(X) ~> bindGlobal(Xs)
  rule bindGlobal(.NAMES) => .
  rule bindNonlocal(X, Xs) => bindNonlocal(X) ~> bindNonlocal(Xs)
  rule bindNonlocal(.NAMES) => .

  rule <k> bindGlobal(X) => . ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <globals>... . => SetItem(X) ...</globals>

  rule <k> bindNonlocal(X) => . ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <nonlocals>... . => SetItem(X) ...</nonlocals>

  rule <k> bindLocal(X,_) => . ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <globals>... SetItem(X) ...</globals>

  rule <k> bindLocal(X,_) => . ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <nonlocals>... SetItem(X) ...</nonlocals>

  rule <k> bindLocal(X,N2) => bind(X,N2) ...</k>
       <currentBlock> N </currentBlock>
       <blockId> N </blockId>
       <globals> Globals:Set </globals>
       <nonlocals> Nonlocals:Set </nonlocals> when notBool(X in Globals orBool X in Nonlocals)

end module
