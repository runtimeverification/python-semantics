require "python-semantics-logic.k"

module PYTHON-SEMANTICS-COMMON
  imports PYTHON-SEMANTICS-LOGIC

  configuration <T>
                  <k> initialize($PGM:K) </k>
                  <control>
                    <xstack> .List </xstack>
                    <xcontext> ref("None") </xcontext>
                    <currentFrame> .K </currentFrame>
                    <lstack> .List </lstack>
                    <fstack> .List </fstack>
                    <scope> .List </scope>
                  </control>
                  <store>
                    <object multiplicity="*">
                      <id> 0 </id>
                      <oenv> .Map </oenv>
                      <oattrs> .Map </oattrs>
                    </object>
                  </store>
                  <symbols> .Map </symbols>
                  <references> "None" |-> 1 </references>
                  <literals> .Map </literals>
                  <nextLoc> 1 </nextLoc>
                  <debug> true </debug>
                  <hashInfo> ListItem(64) ListItem(2305843009213693951) ListItem(314159) ListItem(0) ListItem(1000003) </hashInfo>
//                  <debug> $DEBUG:Bool </debug>
//                  <hashInfo> $HASHINFO:List </hashInfo>
                </T>

  syntax K ::= "initialize" "(" K ")"
             | "bind" "(" NAME "," Builtin ")" 
             | "unbind" "(" NAME ")"
             | "mapping" "(" Expression "," K ")" [strict(1)]
             | "addItem" "(" Expression ")" [strict]
             | "addPair" "(" Builtin "," Expression ")" [strict(2)]
             | "popx"
             | "setx" "(" K ")"
             | "newHelper" "(" Expression "," Expression "," Set ")" [strict(1 2)]
             | "raiseInternal" "(" String "," Expression ")" [strict(2)]
             | "setattr" "(" Builtin "," String "," K ")"
             | "setref" "(" Builtin "," String "," Expression ")" [strict(3)]
             | "executeModule" "(" Expression "," Expression "," Expression ")" [strict]
             | "executeFrame" "(" Int "," Expression "," Expression "," Expression "," Expression "," Expression "," Expression "," Map ")" [strict(2 3 4 5 6 7)]
             | "setArgs" "(" Map ")"

  syntax Test ::= "istype" "(" Expression "," Expression ")" [strict]
                | "hasbase" "(" K "," Expression ")" [strict]

  syntax ObjRef ::= "ref" "(" K ")"
                  | "builtin" "(" Id ")"
                  | "gettype" "(" Expression ")"
                  | "getbases" "(" Expression ")"
                  | "getmember" "(" Expression "," Id "," Bool "," Bool "," Bool ")" [strict(1)] 
                  | "binaryOp" "(" Expression "," Expression "," String "," String "," K ")" [strict(1 2)]
                  | "unaryOp" "(" Expression "," String "," K ")" [strict(1)]
                  | "invoke" "(" Expression "," Map ")" [strict(1)]
                  | "invokeBuiltin" "(" Expression "," List "," Map ")" [strict(1)]
                  | "invokeFunction" "(" Expression "," List "," Map ")" [strict(1)]
                  | "doCall" "(" Expression "," List "," Map ")"
                  | "mutable" "(" Value "," Expression ")" [strict(2)]
                  | "mutable" "(" Map "," Expression ")" [strict(2)]
                  | "immutable" "(" Value "," Expression ")" [strict(2)]
                  | "copy" "(" Expression "," Expression ")" [strict]
                  | "name" "(" Expression ")"
                  | "codeObject" "(" Id "," Parameters "," K "," Bool ")"
                  | "class" "(" Arguments "," Expression ")" [strict(2)]

  syntax K ::= "iterate" "(" Expression "," K ")" [strict(1)]

  rule name(E) => getmember(E, String2Id("__name__"), true, false, true) [macro, anywhere]

  context doCall(HOLE, _, _) when HOLE =/=K .

  syntax String ::= "docString" "(" K ")" [function]
  rule docString(S:String ;) => S [function, anywhere]
  rule docString(S:String ; newline _) => S [function, anywhere]
  rule docString(Lbl:KLabel(_)) => ref("None") when Lbl =/=KLabel '_newline_ andBool Lbl =/=KLabel '_; [function, anywhere]
  rule docString(Lbl:KLabel(Lbl2:KLabel(_),,_)) => ref("None") when Lbl ==KLabel '_newline_ andBool Lbl2 =/=KLabel '_; [function, anywhere]
  rule docString(Lbl:KLabel(Lbl2:KLabel(K),,_)) => ref("None") when Lbl ==KLabel '_newline_ andBool Lbl2 ==KLabel '_; andBool isString(K) =/=K true [function, anywhere]
  rule docString(Lbl:KLabel(K,,_)) => ref("None") when Lbl ==KLabel '_; andBool isString(K) =/=K true [function, anywhere]
  rule docString(.) => ref("None") [function, anywhere]

  syntax Map ::= "Env2Dict" "(" Map ")" [function]
  rule Env2Dict((X |-> K M)) => Id2String(X) |-> K Env2Dict(M) [function, anywhere]
  rule Env2Dict(.) => . [function, anywhere]

  syntax Int ::= "lengthMap" Map [function]
  rule lengthMap(_ |-> _ M:Map) => 1 +Int lengthMap M [function, anywhere]
  rule lengthMap . => 0 [function, anywhere]

  syntax Set ::= "Ids2Strings" "(" Set ")" [function]
  rule Ids2Strings(SetItem(X) St) => SetItem(Id2String(X)) Ids2Strings(St) [function, anywhere]
  rule Ids2Strings(.) => . [function, anywhere]

  syntax List ::= "Listify" "(" K ")" [function]
  rule Listify((P:Parameter , Ps:Parameters)) => ListItem(P) Listify(Ps) [function, anywhere]
  rule Listify(.Parameters) => . [function, anywhere]

  syntax Expressions ::= "DeListify" "(" List ")" [function]
  rule DeListify(ListItem(P) L) => P , DeListify(L) [function, anywhere]
  rule DeListify(.) => .Expressions [function, anywhere]

  syntax List ::= "Idify" "(" List ")" [function]
  rule Idify(ListItem(O) L) => ListItem(id(O)) Idify(L) [function, anywhere]
  rule Idify(.) => . [function, anywhere]

  syntax Set ::= "Setify" "(" List ")" [function]
  rule Setify(ListItem(K) L) => SetItem(K) Setify(L) [function, anywhere]
  rule Setify(.) => . [function, anywhere]

  syntax List ::= "DeSetify" "(" Set ")" [function]
  rule DeSetify(SetItem(K) St) => ListItem(K) DeSetify(St) [function, anywhere]
  rule DeSetify(.) => . [function, anywhere]

  syntax List ::= "sorted" "(" List ")" [function]
  rule sorted(ListItem(K) L) => sorted(less(L, K)) ListItem(K) sorted(more(L, K)) [function, anywhere]
  rule sorted(.) => . [function, anywhere]

  syntax List ::= "less" "(" List "," K ")" [function]
  rule less((ListItem(K) L), K2:K) => ListItem(K) less(L, K2) when lt(K, K2) [function, anywhere]
  rule less((ListItem(K) L), K2) => less(L, K2) when notBool lt(K, K2) [function, anywhere]
  rule less(.,_) => . [function, anywhere]

  syntax List ::= "more" "(" List "," K ")" [function]
  rule more((ListItem(K) L), K2) => ListItem(K) more(L, K2) when notBool lt(K, K2) [function, anywhere]
  rule more((ListItem(K) L), K2) => more(L, K2) when lt(K, K2) [function, anywhere]
  rule more(.,_) => . [function, anywhere]

  syntax Bool ::= "lt" "(" K "," K ")" [function]
  rule lt(S:String, I:Int) => true [function, anywhere]
  rule lt(I:Int, S:String) => false [function, anywhere]
  rule lt(S:String, S2:String) => S <String S2 [function, anywhere]
  rule lt(I:Int, I2:Int) => I <Int I2 [function, anywhere]

  syntax Set ::= "lookup" "(" Map "," Set ")" [function]
  rule lookup((K |-> K2 M), (SetItem(K) St)) => SetItem(K2) lookup(M, St) [function, anywhere]
  rule lookup(_, .) => . [function, anywhere]

  syntax Map ::= "Mapify" "(" KeyData ")" [function]
  rule Mapify((K : K2 , KD:KeyData)) => K |-> K2 Mapify(KD) [function, anywhere]
  rule Mapify(.KeyData) => . [function, anywhere]

  syntax KeyData ::= "DeMapify" "(" Map ")" [function]
  rule DeMapify((K |-> K2 M)) => (K : K2) , DeMapify(M) [function, anywhere]
  rule DeMapify(.) => .NAMES [function, anywhere]

  syntax Builtin ::= "id" "(" Expression ")" [function]
  rule id(obj(B,_)) => B [function, anywhere]
  rule id(undefined(S)) => undefined(S) [function, anywhere]

  syntax Int ::= "intvalue" "(" Expression ")" [function]
  rule intvalue(obj(_,<oattrs>... "__value__" |-> I:Int ...</oattrs>)) => I [function, anywhere]

  syntax String ::= "strvalue" "(" Object ")" [function]
  rule strvalue(obj(_,<oattrs>... "__value__" |-> S:String ...</oattrs>)) => S [function, anywhere]

  syntax List ::= "listvalue" "(" Object ")" [function]
  rule listvalue(obj(_,<oattrs>... "__value__" |-> list(L:List) ...</oattrs>)) => L [function, anywhere]

  syntax Map ::= "mapvalue" "(" Object ")" [function]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ _ |-> list(_ (ListItem(K : K2) => .) _)) ...</oattrs>)) (. => K |-> K2) [function, anywhere]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>)) [function, anywhere]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => . [function, anywhere]

  syntax K ::= "get" "(" List "," Int ")" [function]
  rule get(ListItem(K) _, 0) => K [function, anywhere]
  rule get(ListItem(_) L, N) => get(L, N -Int 1) when N >Int 0 [function, anywhere]

  syntax List ::= "getl" "(" K ")" [function]
  rule getl(list(L)) => L [function, anywhere]

  syntax K ::= "getattr" "(" Expression "," String ")" [function]
  rule getattr(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => Attrs(S) [function, anywhere]

  syntax K ::= "getattr2" "(" Expression "," String ")" [strict(1)]
  rule getattr2(O:Object, S:String) => getattr(O, S)

  syntax ObjRef ::= "getref" "(" Expression "," String ")" [function]
  rule getref(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => ref(Attrs(S)) [function, anywhere]

  syntax ObjRef ::= "getref2" "(" Expression "," String ")" [strict(1)]
  rule getref2(O:Object, S:String) => getref(O, S)

  syntax Set ::= Set "&Set" Set [function]
  rule St1:Set &Set St2:Set => St1 -Set (St1 -Set St2) [function, anywhere]

  syntax Set ::= "values" Map [function]
  rule values (K |-> K2 M) => SetItem(K2) values M [function, anywhere]
  rule values . => . [function, anywhere]

  syntax Bool ::= "all" "(" List "," KLabel ")" [function]
  rule all(ListItem(K) L:List, Lbl:KLabel) => Lbl(K) andBool all(L, Lbl) [function, anywhere]
  rule all(., _) => true [function, anywhere]

  rule <k> setattr(B, S, K) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> Attrs => Attrs[K / S] </oattrs>
       ...</object>

  context setattr(id(HOLE), _, _)
 
  rule <k> setref(B, S, O) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> Attrs => Attrs[id(O) / S] </oattrs>
       ...</object>

  syntax ListItem ::= "(" K "," Bag "," List "," List "," List "," K ")"

  rule binaryOp(O, O2:Object, S, S2, K:K) => test(and(istype(O, ref(S)), istype(O2, ref(S2))), K, ref("NotImplemented"))
  rule unaryOp(O, S, K) => test(istype(O, ref(S)), K, ref("NotImplemented"))

  rule gettype(E:Expression) => getref(E, "__class__") [macro, anywhere]
  rule getbases(E) => getattr2(getref2(E, "__bases__"), "__value__") [macro, anywhere]

  //TODO: subclasshook
  rule istype(O:Object, Type:Object) => hasbase(gettype(O), Type)

  //needs predicates to work without obj()
  rule hasbase(obj(N:Int,ObjState:Bag), Base:Object) => or(obj(N,ObjState) ==K Base, hasbase(getbases(obj(N,ObjState)), Base))

  rule hasbase(list(ListItem(N) L), Base) => or(hasbase(ref(N), Base),hasbase(list(L), Base))
  rule hasbase(list(.List), Base) => false

  rule <k> invokeBuiltin(obj("get_ref",_), ListItem(obj(_, <oattrs>... "__get__" |-> S ...</oattrs>)) ListItem(O) ListItem(_), .) => getref(O, S) ...</k>
  rule <k> invokeBuiltin(obj("get_attr",_), ListItem(obj(_, <oattrs>... "__get__" |-> S ...</oattrs>)) ListItem(O) ListItem(_), .) => getattr(O, S) ...</k>

  rule <k> ref(S:String) => ref(N:Int) ...</k>
       <symbols>... S |-> N ...</symbols>

  rule <k> ref(S:String) => obj(S2:String,<oattrs>Attrs</oattrs>) ...</k>
       <symbols>... S |-> S2 ...</symbols>
       <object>...
         <id>S2</id>
         <oattrs>Attrs</oattrs>
       ...</object>

 rule <k> ref(N:Int) => obj(N,<oattrs>Attrs</oattrs>) ...</k>
       <object>...
         <id>N</id>
         <oattrs>Attrs</oattrs>
       ...</object>

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> N "__method__" |-> T:Bool ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when (T andBool lengthList L -Int 1 =/=Int N) orBool ((notBool T) andBool lengthList L =/=Int N)

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at least " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when N =/=Int I andBool ((T andBool lengthList L -Int 1 <Int N) orBool ((notBool T) andBool lengthList L <Int N))

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at most " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when I >=Int 0 andBool N =/=Int I andBool ((T andBool lengthList L -Int 1 >Int I) orBool ((notBool T) andBool lengthList L >Int I))

  context list(.) ~> iterate(HOLE,_)

  rule iterate(O, K) => try: (list(.) ~> iterate(ref("iter") (O, .Arguments), K)) except ref("TypeError") : test(K ==K ., raise, K) else: pass
  rule list(L:List) ~> iterate(O:Object, K) => try: addItem(getmember(O,  String2Id("__next__"), true, false, false) (.Arguments)) except ref("StopIteration") : list(L) else: (list(L) ~> iterate(O, K))
  rule (addItem(O:Object) => .) ~> popx ~> list(_ (. => ListItem(O)))
  rule K ~> setx(K2) => setx(K2) ~> K when isKResult(K)
  rule K ~> popx => popx ~> K when isKResult(K)

  rule <k> mapping(O, K) => iterate(getmember(O, String2Id("keys"), true, false, false) (.Arguments) -> K, raiseInternal("TypeError", "o.keys() are not iterable")) ~> map(.) ~> mapping(O, K) ...</k>
  rule <k> list((ListItem(B:Builtin) => .) _) ~> (. => addPair(B, (O [ ref(B) ]))) ~> map(_) ~> mapping(O,_) ...</k>
  rule <k> list(_) ~> (addPair(B, O) => .) ~> map(_ (. => B |-> O)) ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> (mapping(_,_) => .) ...</k>

  rule <k> newHelper(O:Object, Type:Object, St:Set) => test(hasbase(O, Type), test(id(O) in lookup(Sym, St), raiseInternal("TypeError", "unsafe builtin __new__ call error message"), .), raiseInternal("TypeError", "invalid builtin __new__ call argument type error message")) ...</k>
       <symbols> Sym:Map </symbols>

  rule raiseInternal(S, O) => raise mutable("args" |-> undefined(strvalue(O)),ref(S))

  rule <k> executeModule(CO:Object, Builtins:Object, Dict:Object) => (Dict [ "__name__"], .Expressions := CO . String2Id("co_name")) ~> (Dict [ "__doc__" ], .Expressions := CO . String2Id("co_consts") [0]) ~> (Dict [ "__builtins__" ], .Expressions := Builtins) ~> setref(id(CO), "co_names", (getref(CO, "co_varnames") + getref(CO, "co_cellvars") + getref(CO, "co_names"))) ~> setref(id(CO), "co_varnames", tuple(.Expressions)) ~> setref(id(CO), "co_cellvars", tuple(.Expressions)) ~> executeFrame(N:Int +Int 1, ref(id(CO)), ref("None"), Dict, Dict, Builtins, {.KeyData}, .) ...</k>
       <nextLoc> N => N +Int 2 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> id(Dict) "__class__" |-> Module </oattrs>
       ...</object>)
       <symbols>... "module" |-> Module:Int ...</symbols>


  rule <k> executeFrame(N, CO:Object, Back:Object, Locals:Object, Globals:Object, Builtins:Object, Cells:Object, Args:Map) => setref(N, "f_code", CO) ~> setref(N, "f_back", Back) ~> setref(N, "f_locals", Locals) ~> setref(N, "f_globals", Globals) ~> test(istype(Builtins, ref("module")), setref(N, "f_builtins", Builtins . String2Id("__dict__")), setref(N, "f_builtins", Builtins)) ~> setref(N, "f_cells", Cells) ~> setArgs(Args) ~> getattr(CO, "co_code") ...</k>
       <currentFrame> _ => N </currentFrame>
       (. => <object>...
         <id>N</id>
         <oattrs> "__class__" |-> Frame </oattrs>
       ...</object>)
       <symbols>... "frame" |-> Frame:Int ...</symbols>

  rule (. => X:Id, .Expressions := ref(B)) ~> setArgs((X |-> B => .) _)
  rule setArgs(.) => .

endmodule
