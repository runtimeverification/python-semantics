require "python-semantics-literals.k"

module PYTHON-SEMANTICS-CALLS
  imports PYTHON-SEMANTICS-LITERALS

  syntax K ::= "processArgs" "(" List "," Map "," Exp "," Exp ")" [strict(3, 4)]
             | "sortArgs" "(" List ")"
             | "matchArgs" "(" Exp "," Exp "," List "," Map "," Map "," Int "," Bool "," Bool ")" [strict(1, 2)]
             | "addArg" "(" Exp "," Exp ")" [strict]
             | "addKwArg" "(" String "," Exp "," Exp ")" [strict(2)]
             | "addDefaults" "(" Int "," Exp ")" [strict(2)]
             | "addDefault" "(" Exp ")" [strict]
             | "addKwDefaults" "(" Int "," Exp ")" [strict(2)]
             | "addKwDefault" "(" Exp ")" [strict]

  syntax Int ::= "numArgs" "(" Object ")" [function]
  rule numArgs(O) => getattr(O, "co_argcount") +Int getattr(O, "co_kwonlyargcount") +Int ((getattr(O, "co_flags") &Int 4) >>Int 2) +Int ((getattr(O, "co_flags") &Int 8) >>Int 3) 

  rule <k> obj(S:String,ObjState:Bag) (Args:K) => sortArgs(Listify(Args)) ~> processArgs(.,.,.Obj,.Obj) ~> invokeBuiltin(obj(S,ObjState), ., .) ...</k> when isKResult(Args)
  rule <k> invokeBuiltin(obj("call_function",_), ListItem(O:Object) L:List, M:Map) => invokeFunction(O, L, M) ...</k>
  rule <k> invokeFunction(O, L, M) => matchArgs(O, O . String2Id("__code__"), L, M, ., 0, false, false) ...</k>

  rule isKResult((_:NAME = K)::Argument) => true when isKResult(K) 

  rule sortArgs((ListItem(O:Object) => .) _) ~> processArgs(_ (. => ListItem(O)),.,_,_)
  rule sortArgs((ListItem((X:Id = O:Object)::Argument) => .) _) ~> processArgs(_,M (. => Id2String(X) |-> O),_,_) when notBool(Id2String(X) in keys(M))
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
  rule (. => addArg(Code . String2Id("co_varnames") [N:Int], O)) ~> matchArgs(_, Code:Object, (ListItem(O) => .) _, _, _, (N => N +Int 1), _, _) when N <Int getattr(Code, "co_argcount")

  //leftover positional arguments get stored in vararg
  rule (. => addArg(Code . String2Id("co_varnames") [getattr(Code, "co_argcount") +Int getattr(Code, "co_kwonlyargcount")], tuple(DeListify(L:List)))) ~> matchArgs(_, Code:Object, (L => .), _, _, N, (false => true), _) when N >=Int getattr(Code, "co_argcount") andBool (getattr(Code, "co_flags") &Int 4) =/=Int 0

  rule (addArg(O:Object, O2:Object) => .) ~> matchArgs(_,_,_,_,_ (. => String2Id(strvalue(O)) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, O2:Object) => .) ~> addKwArg(_,_,_) ~> matchArgs(_,_,_,_,_ (. => String2Id(strvalue(O)) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, O2:Object) => .) ~> addDefaults(_,_) ~> addKwDefaults(_,_) ~> matchArgs(_,_,_,_,_ (. => String2Id(strvalue(O)) |-> ref(id(O2))), _, _, _)
  rule (addArg(O:Object, O2:Object) => .) ~> addKwDefaults(_,_) ~> matchArgs(_,_,_,_,_ (. => String2Id(strvalue(O)) |-> ref(id(O2))), _, _, _)

  // if there is no vararg, leftover positional arguments raise TypeError
  rule matchArgs(Function:Object, Code:Object, ListItem(_) L, _, _, N, _, _) => raiseInternal("TypeError", name(Function) + "() takes at most " +String Int2String(getattr(Code, "co_argcount")) +String " positional arguments (" +String Int2String(N +Int lengthList L +Int 1) +String " given)") when N >=Int getattr(Code, "co_argcount") andBool (getattr(Code, "co_flags") &Int 4) ==Int 0

  // keyword arguments fill positional and kwonly arguments
  rule (. => if S in Code . String2Id("co_varnames") [0 : getattr(Code, "co_argcount") +Int getattr(Code, "co_kwonlyargcount") : ] : addArg(S, O) else: addKwArg(S, O, Code . String2Id("co_varnames") [numArgs(Code) -Int 1])) ~> matchArgs(_, Code:Object, ., (S |-> O => .) _, M, _, _, HasKwarg) when notBool(String2Id(S) in keys(M)) andBool (HasKwarg orBool getattr(Code, "co_flags") &Int 8 ==Int 0)
 
  // cannot specify a parameter both positionally and as a keyword
  rule matchArgs(Function:Object, Code:Object, ., _ (S |-> _), _ (X |-> _), _, _, _) => raiseInternal("TypeError", name(Function) + "() got multiple values for keyword argument '" +String S +String "'") when Id2String(X) ==String S

  // create dict for kwargs if present
  rule (. => addArg(Code . String2Id("co_varnames") [numArgs(Code) -Int 1], {.KeyData})) ~> matchArgs(_, Code:Object, _, _, M, _, _, (false => true)) when (getattr(Code, "co_flags") &Int 8) =/=Int 0

  // fill in default value for unspecified parameter
  rule (. => addDefaults(0, ref("len")(Function . String2Id("__defaults__")) if Function . String2Id("__defaults__") is not ref("None") else 0) ~> addKwDefaults(0, Function . String2Id("__kwdefaults__"))) ~> matchArgs(Function:Object,Code:Object, ., ., M, _, HasVararg, HasKwarg) when lengthMap M <Int numArgs(Code) andBool (HasVararg orBool getattr(Code, "co_flags") &Int 4 ==Int 0) andBool (HasKwarg orBool getattr(Code, "co_flags") &Int 8 ==Int 0)
  rule (addDefaults(N, _) => .) ~> addKwDefaults(_,_) ~> matchArgs(_,Code:Object, _, _, _, _, _, _) when N ==Int getattr(Code, "co_argcount")
  rule (. => addDefault(Code . String2Id("co_varnames") [N:Int])) ~> addDefaults(N, O:Object) ~> addKwDefaults(_,_) ~> matchArgs(_,Code:Object, _, _, _, _, _, _) when N <Int getattr(Code, "co_argcount")
  rule addDefault(O:Object) ~> addDefaults(N2:Int, O2) ~> addKwDefaults(_,_) ~> matchArgs(Function:Object, Code:Object, _, _, M, N, _, _) => raiseInternal("TypeError", name(Function) + "() takes at least " +String Int2String(getattr(Code, "co_argcount") -Int intvalue(O2)) +String " arguments (" +String Int2String(N) +String " given)") when notBool(String2Id(strvalue(O)) in keys(M)) andBool N2 <Int getattr(Code, "co_argcount") -Int intvalue(O2)
  rule (addDefault(O:Object) => #if String2Id(strvalue(O)) in keys(M) #then . #else addArg(O, (Function . String2Id("__defaults__") [N -Int getattr(Code, "co_argcount") +Int intvalue(O2)])) #fi) ~> addDefaults((N => N +Int 1), O2) ~> addKwDefaults(_,_) ~> matchArgs(Function:Object, Code:Object, _, _, M, _, _, _) when N >=Int getattr(Code, "co_argcount") -Int intvalue(O2) orBool String2Id(strvalue(O)) in keys(M)
  rule (addKwDefaults(N, _) => .) ~> matchArgs(_, Code:Object, _, _, _, _, _, _) when N ==Int getattr(Code, "co_kwonlyargcount")
  rule (. => addKwDefault(Code . String2Id("co_varnames") [N +Int getattr(Code, "co_argcount")])) ~> addKwDefaults((N => N +Int 1), _:Object)~> matchArgs(_, Code:Object, _, _, _, _, _, _) when N <Int getattr(Code, "co_kwonlyargcount")
  rule (addKwDefault(O:Object) => #if String2Id(strvalue(O)) in keys(M) #then . #else if O in O2 : addArg(O, O2[O]) else: raiseInternal("TypeError", name(Function) + "() needs keyword-only argument " +String strvalue(O)) #fi) ~> addKwDefaults(_, O2) ~> matchArgs(Function:Object, Code:Object, _, _, M, _, _, _)

  context addKwArg(S, _, HOLE) ~> matchArgs(_, Code:Object, _, _, _, _, _, _) when (getattr(Code, "co_flags") &Int 8) =/=Int 0
  rule addKwArg(S, _, _) ~> matchArgs(Function:Object, Code:Object, _, _, _, _, _, _) => raiseInternal("TypeError", name(Function) + "() got an unexpected keyword argument '" +String S +String "'") when (getattr(Code, "co_flags") &Int 8) ==Int 0
  rule (addKwArg(S:String, O:Object, O2:Object) => M:Map(String2Id(strvalue(O2))) [S:String] = O) ~> matchArgs(_, Code:Object, _, _, M, _, _, _) when (getattr(Code, "co_flags") &Int 8) =/=Int 0

  rule <k> matchArgs(obj(B:ObjId,_),Code:Object,.,.,M,_, HasVararg, HasKwarg) => invoke(ref(B), M) ...</k> when lengthMap M ==Int numArgs(Code) andBool (HasVararg orBool getattr(Code, "co_flags") &Int 4 ==Int 0) andBool (HasKwarg orBool getattr(Code, "co_flags") &Int 8 ==Int 0)

  syntax ListItem ::= (K, Bag, Int, List)
  syntax ObjRef ::= makeLocals(Exp, Exp) [strict(1, 2)]
                  | makeLocals(List, List, Exp) [strict(3)]
                  | makeCells(Exp, Exp, Exp, Int) [strict(1, 2, 3)]
                  | makeCells(List, List, List, Exp, Int) [strict(4)]

  rule <k> invoke(obj(_:Int,<oattrs>... "__closure__" |-> Closure "__code__" |-> ref(Code) "__globals__" |-> Globals ...</oattrs>), M) ~> K:K => executeFrame(N, ref(Code), ref(Frame), makeLocals(ref(Code) . String2Id("co_freevars"), Closure), Globals, Globals ["__builtins__"], makeCells(ref(Code) . String2Id("co_freevars"), ref(Code) . String2Id("co_cellvars"), Closure, N), M) ~> return </k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <control>...
         <currentFrame>
           <frameObject> Frame:Int => N </frameObject> 
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

  rule makeLocals(Free:Object, O:Object) => makeLocals(listvalue(Free), listvalue(O), {.KeyData})
  rule (. => test(getattr2(E2, "cell_contents") ==Obj .Obj, ., (O[E:K] = getref2(E2, "cell_contents")))) ~> makeLocals((ListItem(E) => .) _, (ListItem(E2) => .) _, O:Object)
  rule makeLocals(.List, .List, O:Object) => ref(id(O))

  rule makeCells(Free:Object, Cells:Object, O:Object, N) => makeCells(listvalue(Free), listvalue(Cells), listvalue(O), {.KeyData}, N)
  rule (. => O[E:K] = E2 ::Exp) ~> makeCells((ListItem(E) => .) _, _, (ListItem(E2) => .) _, O:Object, _)
  rule <k> (. => O[E] = ref(N2)) ~> makeCells(_, (ListItem(E) => .) _, _, O:Object, Frame:Int) ...</k>
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
