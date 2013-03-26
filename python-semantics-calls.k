require "python-semantics-literals.k"

module PYTHON-SEMANTICS-CALLS
  imports PYTHON-SEMANTICS-LITERALS

  syntax K ::= "processArgs" "(" List "," Map "," Expression "," Expression ")" [strict(3, 4)]
             | "sortArgs" "(" List ")"
             | "matchArgs" "(" Expression "," Expression "," List "," Map "," Map "," Int "," Bool "," Bool ")" [strict(1, 2)]
             | "addArg" "(" Expression "," Expression ")" [strict]
             | "addKwArg" "(" String "," Expression "," Expression ")" [strict(2)]
             | "addDefaults" "(" Int "," Expression ")" [strict(2)]
             | "addDefault" "(" Expression ")" [strict]
             | "addKwDefaults" "(" Int "," Expression ")" [strict(2)]
             | "addKwDefault" "(" Expression ")" [strict]
             | "invokeBuiltin" "(" Expression "," List "," Map ")" [strict(1)]
             | "invokeFunction" "(" Expression "," List "," Map ")" [strict(1)]

  syntax Int ::= "numArgs" "(" Object ")" [function]
  rule numArgs(O) => getattr(O, "co_argcount") +Int getattr(O, "co_kwonlyargcount") +Int ((getattr(O, "co_flags") &Int 4) >>Int 2) +Int ((getattr(O, "co_flags") &Int 8) >>Int 3) [function, anywhere]

  //can't use descriptors because method descriptors use it
  rule [call]: obj(N:Int,ObjState:Bag) (Args:K) => (getmember(obj(N,ObjState), "__call__", false, false, false) (obj(N,ObjState), Args)) -> (raiseInternal("TypeError", "object is not callable"))
  rule <k> obj(S:String,ObjState:Bag) (Args:K) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeBuiltin(obj(S,ObjState), ., .) ...</k> when isKResult(Args)
  rule <k> invokeBuiltin(O:Object, L:List, M:Map) => invokeFunction(O, L, M) ...</k> when isBareFunction(id(O)) =/=K true
  rule <k> invokeBuiltin(obj("function.__call__",_), ListItem(O:Object) L, M) => invokeFunction(O, L, M) ...</k>
  rule <k> invokeFunction(O, L, M) => matchArgs(O, getref(O, "__code__"), L, M, ., 0, false, false) ...</k>

  rule isBareFunction("function.__call__") => true

  rule isKResult(_ = K) => true when isKResult(K) [function, anywhere]

  rule sortArgs((ListItem(O:Object) => .) _) ~> processArgs(_ (. => ListItem(O)),.,_,_)
  rule sortArgs((ListItem(X:Id = O:Object) => .) _) ~> processArgs(_,M (. => Id2String(X) |-> O),_,_) when notBool(Id2String(X) in keys(M))
  rule sortArgs((ListItem(* O:Object) => .) _) ~> processArgs(_,_,(_ => O),_)
  rule sortArgs((ListItem(** O:Object) => .) _) ~> processArgs(_,_,_,(_ => O))
  rule sortArgs(.) => .

  rule (. => iterate(O:Object, raiseInternal("TypeError", "argument after * must be a sequence"))) ~> processArgs(_,_,O,_)
  rule (list(L:List) => .) ~> processArgs(_ (. => L),_,(_:Object => .Obj),_)
  rule (. => mapping(O:Object, raiseInternal("TypeError", "argument after ** must be a mapping"))) ~> processArgs(_,_,.Obj,O)
  rule (. => test(istype(O, ref("str")), ., raiseInternal("TypeError", "keywords must be strings"))) ~> map(_ (O:Object |-> O2:Object => .)) ~> processArgs(_,_ (. => strvalue(O) |-> O2),.Obj,_)
  rule (map(.) => .) ~> processArgs(_,_,.Obj,(_:Object => .Obj))

  rule (processArgs(L, M:Map, .Obj, .Obj) => .) ~> invokeBuiltin(_, (. => L), (. => M))

  //process positional arguments
  rule <k> (. => addArg(get(L, N), O)) ~> matchArgs(_, obj(Code:ObjId,ObjState:Bag), (ListItem(O) => .) _, _, _, (N => N +Int 1), _, _) ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(Varnames) ...</oattrs>
       ...</object>
       <object>...
         <id> Varnames </id>
         <oattrs>... "__value__" |-> list(L:List) ...</oattrs>
       ...</object> when N <Int getattr(obj(Code,ObjState), "co_argcount")

  //leftover positional arguments get stored in vararg
  rule <k> (. => addArg(get(L, getattr(obj(Code,ObjState), "co_argcount") +Int getattr(obj(Code,ObjState), "co_kwonlyargcount")), tuple(DeListify(Args:List)))) ~> matchArgs(_, obj(Code:ObjId,ObjState:Bag), (Args => .), _, _, N, (false => true), _)  ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(Varnames) ...</oattrs>
       ...</object>
       <object>...
         <id> Varnames </id>
         <oattrs>... "__value__" |-> list(L:List) ...</oattrs>
       ...</object> when N >=Int getattr(obj(Code,ObjState), "co_argcount") andBool (getattr(obj(Code,ObjState), "co_flags") &Int 4) =/=Int 0

  rule (addArg(O:Object, O2:Object) => .) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, O2:Object) => .) ~> addKwArg(_,_,_) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, O2:Object) => .) ~> addDefaults(_,_) ~> addKwDefaults(_,_) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, O2:Object) => .) ~> addKwDefaults(_,_) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, .Obj) => .) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> .Obj), _, _, _)
  rule (addArg(O:Object, .Obj) => .) ~> addKwArg(_,_,_) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> .Obj), _, _, _)
  rule (addArg(O:Object, .Obj) => .) ~> addDefaults(_,_) ~> addKwDefaults(_,_) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> .Obj), _, _, _)
  rule (addArg(O:Object, .Obj) => .) ~> addKwDefaults(_,_) ~> matchArgs(_,_,_,_,_ (. => strvalue(O) |-> .Obj), _, _, _)

  // if there is no vararg, leftover positional arguments raise TypeError
  rule matchArgs(Function:Object, Code:Object, ListItem(_) L, _, _, N, _, _) => raiseInternal("TypeError", name(Function) + "() takes at most " +String Int2String(getattr(Code, "co_argcount")) +String " positional arguments (" +String Int2String(N +Int lengthList L +Int 1) +String " given)") when N >=Int getattr(Code, "co_argcount") andBool (getattr(Code, "co_flags") &Int 4) ==Int 0

  // keyword arguments fill positional and kwonly arguments
  rule (. => if S in Code . String2Id("co_varnames") [0 : getattr(Code, "co_argcount") +Int getattr(Code, "co_kwonlyargcount") : ] : addArg(S, O) else: addKwArg(S, O, Code . String2Id("co_varnames") [numArgs(Code) -Int 1])) ~> matchArgs(_, Code:Object, ., (S |-> O => .) _, M, _, _, HasKwarg) when notBool(String2Id(S) in keys(M)) andBool (HasKwarg orBool getattr(Code, "co_flags") &Int 8 ==Int 0)
 
  // cannot specify a parameter both positionally and as a keyword
  rule matchArgs(Function:Object, Code:Object, ., _ S |-> _, _ X |-> _, _, _, _) => raiseInternal("TypeError", name(Function) + "() got multiple values for keyword argument '" +String S +String "'") when X ==String S

  // create dict for kwargs if present
  rule <k> (. => addArg(get(L, numArgs(obj(Code,ObjState)) -Int 1), {.KeyData})) ~> matchArgs(_, obj(Code,ObjState:Bag), _, _, M, _, _, (false => true)) ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(Varnames) ...</oattrs>
       ...</object>
       <object>...
         <id> Varnames </id>
         <oattrs>... "__value__" |-> list(L:List) ...</oattrs>
       ...</object> when (getattr(obj(Code,ObjState), "co_flags") &Int 8) =/=Int 0

  // fill in default value for unspecified parameter
  rule (. => addDefaults(0, ref("len")(getref(Function, "__defaults__")) if getref(Function, "__defaults__") is not None else 0) ~> addKwDefaults(0, getref(Function, "__kwdefaults__"))) ~> matchArgs(Function:Object,Code:Object, ., ., M, _, HasVararg, HasKwarg) when lengthMap M <Int numArgs(Code) andBool (HasVararg orBool getattr(Code, "co_flags") &Int 4 ==Int 0) andBool (HasKwarg orBool getattr(Code, "co_flags") &Int 8 ==Int 0)
  rule (addDefaults(N, _) => .) ~> addKwDefaults(_,_) ~> matchArgs(_,Code:Object, _, _, _, _, _, _) when N ==Int getattr(Code, "co_argcount")
  rule <k> (. => addDefault(get(L, N))) ~> addDefaults(N, O:Object) ~> addKwDefaults(_,_) ~> matchArgs(_,obj(Code:ObjId,ObjState:Bag), _, _, _, _, _, _) ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(Varnames) ...</oattrs>
       ...</object>
       <object>...
         <id> Varnames </id>
         <oattrs>... "__value__" |-> list(L) ...</oattrs>
       ...</object> when N <Int getattr(obj(Code,ObjState), "co_argcount")
  rule addDefault(O:Object) ~> addDefaults(N2:Int, O2) ~> addKwDefaults(_,_) ~> matchArgs(Function:Object, Code:Object, _, _, M, N, _, _) => raiseInternal("TypeError", name(Function) + "() takes at least " +String Int2String(getattr(Code, "co_argcount") -Int intvalue(O2)) +String " arguments (" +String Int2String(N) +String " given)") when notBool(strvalue(O) in keys(M)) andBool N2 <Int getattr(Code, "co_argcount") -Int intvalue(O2)
  rule <k> (addDefault(O:Object) => #if strvalue(O) in keys(M) #then . #else addArg(O, get(L, N -Int getattr(Code, "co_argcount") +Int intvalue(O2))) #fi) ~> addDefaults((N => N +Int 1), O2) ~> addKwDefaults(_,_) ~> matchArgs(obj(Function:ObjId,ObjState:Bag), Code:Object, _, _, M, _, _, _) ...</k>
       <object>...
         <id> Function </id>
         <oattrs>... "__defaults__" |-> ref(Defaults) ...</oattrs>
       ...</object>
       <object>...
         <id> Defaults </id>
         <oattrs>... "__value__" |-> list(L) ...</oattrs>
       ...</object> when N >=Int getattr(Code, "co_argcount") -Int intvalue(O2) orBool strvalue(O) in keys(M)
  rule (addKwDefaults(N, _) => .) ~> matchArgs(_, Code:Object, _, _, _, _, _, _) when N ==Int getattr(Code, "co_kwonlyargcount")
  rule (. => addKwDefault(Code . String2Id("co_varnames") [N +Int getattr(Code, "co_argcount")])) ~> addKwDefaults((N => N +Int 1), _:Object)~> matchArgs(_, Code:Object, _, _, _, _, _, _) when N <Int getattr(Code, "co_kwonlyargcount")
  rule (addKwDefault(O:Object) => #if strvalue(O) in keys(M) #then . #else if O in O2 : addArg(O, O2[O]) else: raiseInternal("TypeError", name(Function) + "() needs keyword-only argument " +String strvalue(O)) #fi) ~> addKwDefaults(_, O2) ~> matchArgs(Function:Object, Code:Object, _, _, M, _, _, _)

  context addKwArg(S, _, HOLE) ~> matchArgs(_, Code:Object, _, _, _, _, _, _) when (getattr(Code, "co_flags") &Int 8) =/=Int 0
  rule addKwArg(S, _, _) ~> matchArgs(Function:Object, Code:Object, _, _, _, _, _, _) => raiseInternal("TypeError", name(Function) + "() got an unexpected keyword argument '" +String S +String "'") when (getattr(Code, "co_flags") &Int 8) ==Int 0
  rule (addKwArg(S:String, O:Object, O2:Object) => (M:Map(strvalue(O2)) [S:String], .Expressions) := O) ~> matchArgs(_, Code:Object, _, _, M, _, _, _) when (getattr(Code, "co_flags") &Int 8) =/=Int 0

  rule <k> matchArgs(obj(B:ObjId,_),Code:Object,.,.,M,_, HasVararg, HasKwarg) => invoke(ref(B), M) ...</k> when lengthMap M ==Int numArgs(Code) andBool (HasVararg orBool getattr(Code, "co_flags") &Int 4 ==Int 0) andBool (HasKwarg orBool getattr(Code, "co_flags") &Int 8 ==Int 0)

  syntax ListItem ::= (K, Bag, Int, List)
  syntax ObjRef ::= makeLocals(Expression, Expression) [strict(1, 2)]
                  | makeLocals(List, List, Expression) [strict(3)]
                  | makeCells(Expression, Expression, Expression, Int) [strict(1, 2, 3)]
                  | makeCells(List, List, List, Expression, Int) [strict(4)]

  rule <k> invoke(obj(FuncId,<oattrs>... "__closure__" |-> Closure "__code__" |-> ref(Code) "__globals__" |-> Globals ...</oattrs>), M) ~> K:K => executeFrame(N, ref(Code), Frame, makeLocals(getref2(ref(Code), "co_freevars"), Closure), #if Globals ==K .Obj #then { .KeyData } #else Globals #fi, #if Globals ==K .Obj #then { .KeyData } #else Globals . String2Id("get") ("__builtins__", { .KeyData }) #fi, makeCells(getref2(ref(Code), "co_freevars"), getref2(ref(Code), "co_cellvars"), Closure, N), M, isInt(FuncId) =/=K true) ~> return </k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <control>...
         <currentFrame>
           <frameObject> Frame:K => ref(N) </frameObject> 
           <fstack> FL => . </fstack>
           <xcontext> XC </xcontext>
           (C:Bag => newFrame)
         </currentFrame>
         <cstack> . => call(Frame, C, FL, XC, K) ...</cstack>
       ...</control>
       <object>...
         <id>Code</id>
         <oattrs>... "co_flags" |-> Flags ...</oattrs>
       ...</object> when Flags &Int 32 ==Int 0 [allocation]

  syntax Bag ::= "newFrame"
  rule newFrame => <xstack> .List </xstack> <lstack> .List </lstack>

  rule makeLocals(Free:Object, O:Object) => if O is None : makeLocals(listvalue(Free), .List, {.KeyData}) else: makeLocals(listvalue(Free), listvalue(O), {.KeyData})
  rule (. => test(getattr2(N2, "cell_contents") ==Obj .Obj, ., (((O[N:K]), .Expressions) := getref2(N2, "cell_contents")))) ~> makeLocals((ListItem(N) => .) _, (ListItem(N2) => .) _, O:Object)
  rule makeLocals(.List, .List, O:Object) => ref(id(O))

  rule makeCells(Free:Object, Cells:Object, O:Object, N) => if O is None : makeCells(listvalue(Free), listvalue(Cells), .List, {.KeyData}, N) else: makeCells(listvalue(Free), listvalue(Cells), listvalue(O), {.KeyData}, N)
  rule (. => ((O[N:K]), .Expressions) := N2) ~> makeCells((ListItem(N) => .) _, _, (ListItem(N2) => .) _, O:Object, _)
  rule <k> (. => ((O[N:K]), .Expressions) := ref(N2)) ~> makeCells(_, (ListItem(N) => .) _, _, O:Object, Frame:Int) ...</k>
       <nextLoc> N2 => N2 +Int 1 </nextLoc>
       (. => <object>...
         <id>N2</id>
         <oattrs> "__class__" |-> ref("cell") "cell_contents" |-> .Obj "cell_frame" |-> ref(Frame) </oattrs>
       ...</object>) [allocation]

  rule makeCells(.List, .List, .List, O:Object, _) => ref(id(O))

  rule <k> return O ~> _ => O ~> K </k>
       <control>...
         <cstack> call(Frame, C, FL, XC, K) => . ...</cstack>
         <currentFrame>
           <frameObject> _ => Frame </frameObject>
           <fstack> . => FL </fstack>
           <xcontext> _ => XC </xcontext>
           (_ => C)
         </currentFrame>
       ...</control>

  rule <k> (. => Finally:K) ~> return O ...</k>
       <currentFrame>
         <fstack> finally(Finally, C, XL:List, LL:List, _, Ex) => . ...</fstack>
         <xstack> _ => XL </xstack>
         <lstack> _ => LL </lstack>
         <xcontext> _ => Ex </xcontext>
         (_ => C)
       </currentFrame>

endmodule
