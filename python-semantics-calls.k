module PYTHON-SEMANTICS-CALLS
  imports PYTHON-SEMANTICS-LITERALS

  syntax K ::= "processArgs" "(" List "," Map "," Expression "," Expression ")" [:strict(3 4):]
             | "sortArgs" "(" List ")"
             | "matchArgs" "(" Expression "," Expression "," List "," Map "," Map "," #Nat ")" [:strict(1 2):]
             | "addArg" "(" Expression "," Expression ")" [:strict:]
             | "addKwArg" "(" #String "," Expression "," Expression ")" [:strict(2 3):]
             | "addDefaults" "(" #Nat "," Expression ")" [:strict(2):]
             | "addDefault" "(" Expression ")" [:strict:]
             | "addKwDefaults" "(" #Nat "," Expression ")" [:strict(2):]
             | "addKwDefault" "(" Expression ")" [:strict:]

  declare numArgs : Object -> #Nat
  define numArgs(O) => int(getattr(O, "co_argcount")) +Int int(getattr(O, "co_kwonlyargcount")) +Int ((int(getattr(O, "co_flags")) &Int 4) >>Int 2) +Int ((int(getattr(O, "co_flags")) &Int 8) >>Int 3)

  rule <k> obj(S:#String,ObjState:Bag) (Args:K) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeBuiltin(obj(S,ObjState), ., .) ...</k> when 'isKResult(Args)
  rule <k> invokeBuiltin(obj("call_function",_), ListItem(O:Object) L:List, M:Map) => invokeFunction(O, L, M) ...</k>
  rule <k> invokeFunction(O, L, M) => matchArgs(O, O . #id "__code__", L, M, ., 0) ...</k>

  define 'isKResult(_ = K) => true when 'isKResult(K)

  rule sortArgs((ListItem(O) => .) _) ~> processArgs(_ (. => ListItem(O)),.,_,_)
  rule sortArgs((ListItem(X:#Id = O) => .) _) ~> processArgs(_,M (. => Id2String(X) |-> O),_,_) when notBool(Id2String(X) in keys(M))
  rule sortArgs((ListItem(* O) => .) _) ~> processArgs(_,_,(_ => O),_)
  rule sortArgs((ListItem(** O) => .) _) ~> processArgs(_,_,_,(_ => O))
  rule sortArgs(.) => .

  rule (. => iterate(O, raiseInternal("TypeError", "argument after * must be a sequence"))) ~> processArgs(_,_,O,_)
  rule (list(L:List) => .) ~> processArgs(_ (. => L),_,(_:Object => .Obj),_)
  rule (. => mapping(O, raiseInternal("TypeError", "argument after ** must be a mapping"))) ~> processArgs(_,_,.Obj,O)
  rule (. => test(istype(O, ref("str")), ., raiseInternal("TypeError", "keywords must be strings"))) ~> map(_ (O |-> O2:Object => .)) ~> processArgs(_,_ (. => strvalue(O) |-> O2),.Obj,_)
  rule (map(.) => .) ~> processArgs(_,_,.Obj,(_:Object => .Obj))

  rule (processArgs(L, M:Map, .Obj, .Obj) => .) ~> invokeBuiltin(_, (. => L), (. => M))

  //process positional arguments
  rule (. => addArg(Code . #id "co_varnames" [N:#Nat], O)) ~> matchArgs(_, Code:Object, (ListItem(O) => .) _, _, _, (N => sNat(N))) when N <Int int(getattr(Code, "co_argcount"))

  //leftover positional arguments get stored in vararg
  rule (. => addArg(Code . #id "co_varnames" [int(getattr(Code, "co_argcount")) +Int int(getattr(Code, "co_kwonlyargcount"))], tuple(DeListify(L)))) ~> matchArgs(_, Code, (L => .), _, _, N) when N >=Int int(getattr(Code, "co_argcount")) andBool (int(getattr(Code, "co_flags")) &Int 4) =/=Bool 0 andBool L =/=Bool .

  rule (addArg(O, O2) => .) ~> matchArgs(_,_,_,_,_ (. => #id strvalue(O) |-> id(O2)), _)

  // if there is no vararg, leftover positional arguments raise TypeError
  rule matchArgs(Function:Object, Code, ListItem(_) L, _, _, N) => raiseInternal("TypeError", Function . #id "__name__" + "() takes at most " +String Int2String(int(getattr(Code, "co_argcount"))) +String " positional arguments (" +String Int2String(N +Int lengthList L +Int 1) +String " given)") when N >=Int int(getattr(Code, "co_argcount")) andBool (int(getattr(Code, "co_flags")) &Int 4) ==Bool 0

  // keyword arguments fill positional and kwonly arguments
  rule (. => if S in Code . #id "co_varnames" [0 : int(getattr(Code, "co_argcount")) +Int int(getattr(Code, "co_kwonlyargcount"))] : addArg(S, O) else: addKwArg(S, O, Code . #id "co_varnames" [numArgs(Code) -Int 1])) ~> matchArgs(_, Code, ., (S |-> O => .) _, M, _) when notBool(#id S in keys(M))
 
  // cannot specify a parameter both positionally and as a keyword
  rule matchArgs(Function, Code, ., _ S |-> _, _ #id S |-> _, _) => raiseInternal("TypeError", Function . #id "__name__" + "() got multiple values for keyword argument '" +String S +String "'")

  // fill in default value for unspecified parameter
  rule (. => addDefaults(0, ref("len")(Function . #id "__defaults__")) ~> addKwDefaults(0, Function . #id "__kwdefaults__")) ~> matchArgs(Function,Code, ., ., M, _) when lengthMap M <Int numArgs(Code)
  rule (addDefaults(N, _) => .) ~> addKwDefaults(_,_) ~> matchArgs(_,Code, _, _ ,_ ,_) when N ==Bool getattr(Code, "co_argcount")
  rule (. => addDefault(Code . #id "co_varnames" [N])) ~> addDefaults(N => sNat(N), O) ~> addKwDefaults(_,_) ~> matchArgs(_,Code, _, _, _, _) when N <Int int(getattr(Code, "co_argcount"))
  rule addDefault(O) ~> addDefaults(N2:#Nat, O2) ~> addKwDefaults(_,_) ~> matchArgs(Function, Code, _, _, M, N) => raiseInternal("TypeError", Function . #id "__name__" + "() takes at least " +String Int2String(int(getattr(Code, "co_argcount")) -Int intvalue(O2)) +String "arguments (" +String Int2String(N) +String " given)") when notBool(#id strvalue(O) in keys(M)) andBool N2 <Int int(getattr(Code, "co_argcount")) -Int intvalue(O2)
  rule (addDefault(O) => if #id strvalue(O) in keys(M) then . else addArg(O, (Function . #id "__defaults__" [-Int intvalue(O2) +Int N])) fi) ~> addDefaults(N, O2) ~> addKwDefaults(_,_) ~> matchArgs(Function, Code, _, _, M, _) when N >=Int int(getattr(Code, "co_argcount")) -Int intvalue(O2) orBool #id strvalue(O) in keys(M)
  rule (addKwDefaults(N, _) => .) ~> matchArgs(_, Code, _, _, _, _) when N ==Bool getattr(Code, "co_kwonlyargcount")
  rule (. => addKwDefault(Code . #id "co_varnames" [N +Int int(getattr(Code, "co_argcount"))])) ~> addKwDefaults((N => sNat(N)), _) ~> matchArgs(_, Code, _, _, _, _) when N <Int int(getattr(Code, "co_kwonlyargcount"))
  rule (addKwDefault(O) => if #id strvalue(O) in keys(M) then . else if O in O2 : addArg(O, O2[O]) else: raiseInternal("TypeError", Function . #id "__name__" + "() needs keyword-only argument " +String strvalue(O)) fi) ~> addKwDefaults(N, O2) ~> matchArgs(Function, Code, _, _, M, _)

  rule (. => addArg(O, {})) ~> addKwArg(S, _, O) ~> matchArgs(_, Code, _, _, M, _) when notBool(#id strvalue(O) in keys(M)) andBool (int(getattr(Code, "co_flags")) &Int 8) =/=Bool 0
  rule addKwArg(S, _, _) ~> matchArgs(Function, Code, _, _, _, _) => raiseInternal("TypeError", Function . #id "__name__" + "() got an unexpected keyword argument '" +String S +String "'") when (int(getattr(Code, "co_flags")) &Int 8) ==Bool 0
  rule (addKwArg(S, O, O2) => M(#id strvalue(O2)) [S] := O) ~> matchArgs(_, Code, _, _, M, _) when #id strvalue(O2) in keys(M) andBool (int(getattr(Code, "co_flags")) &Int 8) =/=Bool 0

  rule <k> matchArgs(obj(B:Builtin,_),Code,.,.,M,_) => invoke(ref(B), M) ...</k> when lengthMap M ==Bool numArgs(Code)

  syntax ListItem ::= "(" K "," Bag "," #Nat "," List ")"
  syntax ObjRef ::= "makeLocals" "(" Expression "," Expression ")" [:strict(1 2):]
                  | "makeLocals" "(" List "," List "," Expression ")" [:strict(3):]
                  | "makeCells" "(" Expression "," Expression "," Expression "," #Nat ")" [:strict(1 2 3):]
                  | "makeCells" "(" List "," List "," List "," Expression "," #Nat ")" [:strict(4):]

  rule <k> invoke(obj(_:#Nat,<oattrs>... "__closure__" |-> Closure:#Nat "__code__" |-> CodeId:#Nat "__globals__" |-> Globals:#Nat ...</oattrs>), M) ~> K:K => executeFrame(N, ref(CodeId), ref(N2), makeLocals(ref(CodeId) . #id "co_freevars", ref(Closure)), ref(Globals), ref(Globals) ["__builtins__"], makeCells(ref(CodeId) . #id "co_freevars", ref(CodeId) . #id "co_cellvars", ref(Closure), N), M) ~> return </k>
       <nextLoc> N => sNat(N) </nextLoc>
       <control>
         <currentFrame> N2 => N </currentFrame>
         <fstack> . => (K, C, N2, LL) ...</fstack>
         <lstack> LL => . </lstack>
         C:Bag
       </control>

  rule makeLocals(Free:Object, O) => makeLocals(listvalue(Free), listvalue(O), {})
  rule (. => test(getattr(ref(N2), "cell_contents") ==Bool .Obj, ., (((O[ref(N)]), .Expressions) := getref(ref(N2), "cell_contents")))) ~> makeLocals((ListItem(N) => .) _, (ListItem(N2) => .) _, O)
  rule makeLocals(.List, .List, O) => ref(id(O))

  rule makeCells(Free, Cells:Object, O, N) => makeCells(listvalue(Free), listvalue(Cells), listvalue(O), {}, N)
  rule (. => ((O[ref(N)]), .Expressions) := ref(N2)) ~> makeCells((ListItem(N) => .) _, _, (ListItem(N2) => .) _, O, _)
  rule <k> (. => ((O[ref(N)]), .Expressions) := ref(N2)) ~> makeCells(_, (ListItem(N) => .) _, _, O, Frame:#Nat) ...</k>
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
