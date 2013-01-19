require "python-semantics-logic.k"

module PYTHON-SEMANTICS-COMMON
  imports PYTHON-SEMANTICS-LOGIC

  configuration <T>
                  <k> initialize($PGM:K) </k>
                  <control>
                    <currentFrame>
                      <frameObject> .K </frameObject>
                      <xstack> .List </xstack>
                      <xcontext> ref("None") </xcontext>
                      <lstack> .List </lstack>
                      <fstack> .List </fstack>
                    </currentFrame>
                    <cstack> .List </cstack>
                  </control>
                  <scope> .List </scope>
                  <store>
                    <object multiplicity="*">
                      <id> 0 </id>
                      <oenv multiplicity="?"> .Map </oenv>
                      <oattrs> .Map </oattrs>
                    </object>
                  </store>
                  <garbage> .Set </garbage>
                  <gc> 1 </gc>
                  <gcThreshold> $GCTHRESHOLD:Int </gcThreshold>
                  <literals> .Map </literals>
                  <symbols> .Map </symbols>
                  <builtinModules> .Map </builtinModules>
                  <references> .Map </references>
                  <bootstrapping> 3 </bootstrapping>
                  <nextLoc> 1 </nextLoc>
                  <debug> $DEBUG:Bool </debug>
                  <hashInfo> $HASHINFO:List </hashInfo>
                  <hashSeed> $HASHSEED:Int </hashSeed>
                  <sysPath> $SYSPATH:List </sysPath>
                  <importlib> $IMPORTLIB:K </importlib>
                  <os> $OS:K </os>
                </T>

  syntax K ::= "initialize" "(" K ")"
             | "bind" "(" NAME "," ObjId ")" 
             | "unbind" "(" NAME ")"
             | "mapping" "(" Expression "," K ")" [strict(1)]
             | "addItem" "(" Expression ")" [strict]
             | "addPair" "(" Expression "," Expression ")"
             | "popx"
             | setx(K)
             | savetb(Expression) [strict]
             | "newHelper" "(" Expression "," Expression "," Set ")" [strict(1, 2)]
             | "raiseInternal" "(" String "," Expression ")" [strict(2)]
             | "setattr" "(" ObjId "," String "," K ")"
             | "setref" "(" ObjId "," String "," Expression ")" [strict(3)]
             | "setenv" "(" ObjId "," Expression "," Expression ")" [strict(2, 3)]
             | "executeModule" "(" Expression "," Expression "," Expression ")" [strict]
             | executeFrame(Int, Expression, Expression, Expression, Expression, Expression, Expression, Map) [strict(2, 3, 4, 5, 6, 7)]
             | makeFrame(Int, Expression, Expression, Expression, Expression, Expression, Expression, Map) [strict(2, 3, 4, 5, 6, 7)]
             | setArgs(Int, Map)
             | getMro(Expression, Expression) [strict]
             | doBind(String, ObjId, Expression) [strict(3)]

  syntax Test ::= "istype" "(" Expression "," Expression ")" [strict]
                | "hasbase" "(" K "," Expression ")" [strict]

  syntax ObjRef ::= "ref" "(" K ")"
                  | "builtin" "(" Id ")"
                  | "gettype" "(" Expression ")"
                  | "getbases" "(" Expression ")"
                  | "getmember" "(" Expression "," Expression "," Bool "," Bool "," Bool ")" [strict(1, 2)] 
                  | "setmember" "(" Expression "," Expression "," Expression ")" [strict] 
                  | "binaryOp" "(" Expression "," Expression "," String "," String "," K ")" [strict(1, 2)]
                  | "unaryOp" "(" Expression "," String "," K ")" [strict(1)]
                  | "invoke" "(" Expression "," Map ")" [strict(1)]
                  | "invokeBuiltin" "(" Expression "," List "," Map ")" [strict(1)]
                  | "invokeFunction" "(" Expression "," List "," Map ")" [strict(1)]
                  | "doCall" "(" Expression "," List "," Map ")"
                  | "mutable" "(" Value "," Expression ")" [strict(2)]
                  | "mutable" "(" Map "," Expression ")" [strict(2)]
                  | "immutable" "(" Value "," Expression ")" [strict(2)]
                  | "immutable" "(" Map "," Expression ")" [strict(2)]
                  | "name" "(" Expression ")"
                  | "codeObject" "(" Id "," Parameters "," K "," Bool ")"
                  | "class" "(" Arguments "," Expression ")" [strict]
                  | describe(Expression, Expression, Expression, String) [strict(1, 2, 3)]
                  | doDescribe(Expression, Expression, Expression, String) [strict(1, 2, 3)]

  syntax K ::= "iterate" "(" Expression "," K ")" [strict(1)]

  rule name(E) => getmember(E, "__name__", true, false, true) [macro, anywhere]

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

  syntax List ::= "Refify" "(" List ")" [function]
  rule Refify(ListItem(O) L) => ListItem(ref(O)) Refify(L) [function, anywhere]
  rule Refify(.) => . [function, anywhere]

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

  syntax ObjId ::= "id" "(" Expression ")" [function]
  rule id(obj(B,_)) => B
  rule id(undefined(S)) => undefined(S)
  rule id(ref(B)) => B

  syntax Int ::= "intvalue" "(" Expression ")" [function]
  rule intvalue(obj(_,<oattrs>... "__value__" |-> I:Int ...</oattrs>)) => I [function, anywhere]

  syntax Float ::= "floatvalue" "(" Expression ")" [function]
  rule floatvalue(obj(_,<oattrs>... "__value__" |-> F:Float ...</oattrs>)) => F [function, anywhere]

  syntax String ::= "strvalue" "(" Object ")" [function]
  rule strvalue(obj(_,<oattrs>... "__value__" |-> S:String ...</oattrs>)) => S [function, anywhere]

  syntax List ::= "listvalue" "(" Object ")" [function]
  rule listvalue(obj(_,<oattrs>... "__value__" |-> list(L:List) ...</oattrs>)) => L [function, anywhere]

  syntax Map ::= "mapvalue" "(" Object ")" [function]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ _ |-> list(_ (ListItem(K : K2) => .) _)) ...</oattrs>)) (. => K |-> K2) [function, anywhere]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>)) [function, anywhere]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => . [function, anywhere]

  syntax List ::= setvalue(Object) [function]
  rule setvalue(obj(_,<oattrs>... "__value__" |-> map(_ _ |-> list(_ (ListItem(K) => .) _)) ...</oattrs>)) (.List => ListItem(K)) [function, anywhere]
  rule setvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>)) [function, anywhere]
  rule setvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => . [function, anywhere]

  syntax K ::= "get" "(" List "," Int ")" [function]
  rule get(ListItem(K) _, 0) => K [function, anywhere]
  rule get(ListItem(_) L, N) => get(L, N -Int 1) when N >Int 0 [function, anywhere]

  syntax List ::= "getl" "(" K ")" [function]
  rule getl(list(L)) => L [function, anywhere]

  syntax K ::= "getattr" "(" Expression "," String ")" [function]
  rule getattr(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => Attrs:Map(S) [function, anywhere]

  syntax K ::= "getattr2" "(" Expression "," String ")" [strict(1)]
  rule getattr2(O:Object, S:String) => getattr(O, S)

  syntax ObjRef ::= "getref" "(" Expression "," String ")" [function]
  rule getref(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => Attrs:Map(S) [function, anywhere]

  syntax ObjRef ::= "getref2" "(" Expression "," String ")" [strict(1)]
  rule getref2(O:Object, S:String) => getref(O, S)

  syntax Set ::= Set "&Set" Set [function]
  rule St1:Set &Set St2:Set => St1 -Set (St1 -Set St2) [function, anywhere]

  syntax Bool ::= "all" "(" List "," KLabel ")" [function]
  rule all(ListItem(K) L:List, Lbl:KLabel) => Lbl(K) andBool all(L, Lbl) [function, anywhere]
  rule all(., _) => true [function, anywhere]

  syntax String ::= String "*String" Int [function]
  rule S:String *String 0 => ""
  rule S:String *String I:Int => S +String (S *String (I -Int 1)) when I >Int 0

  rule <k> setattr(B, S, K) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> Attrs => Attrs[K / S] </oattrs>
       ...</object>

  context setattr(id(HOLE), _, _)
 
  rule <k> setref(B, S, O) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> Attrs => Attrs[ref(id(O)) / S] </oattrs>
       ...</object>

  context setref(id(HOLE), _, _)

  rule <k> setenv(B, O, O2) => . ...</k>
       <object>...
         <id>B</id>
         <oenv> Env => Env [ id(O2) / id(O) ] </oenv>
       ...</object>

  syntax ListItem ::= finally(K, Bag, List, List, List, K)
                    | call(K, Bag, List, K, K)
                    | generator(K, Bag, List, K, K, ObjId)

  rule binaryOp(O, O2:Object, S, S2, K:K) => test(and(istype(O, ref(S)), istype(O2, ref(S2))), K, ref("NotImplemented"))
  rule unaryOp(O, S, K) => test(istype(O, ref(S)), K, ref("NotImplemented"))

  rule gettype(E:Expression) => getref(E, "__class__") [macro, anywhere]
  rule getbases(E) => getattr2(getref2(E, "__bases__"), "__value__") [macro, anywhere]

  rule istype(O:Object, Type:Object) => hasbase(gettype(O), Type)

  //needs predicates to work without obj()
  rule hasbase(obj(N:Int,ObjState:Bag), Base:Object) => or(obj(N,ObjState) ==K Base, hasbase(getbases(obj(N,ObjState)), Base))

  rule hasbase(list(ListItem(N) L), Base) => or(hasbase(N, Base),hasbase(list(L), Base))
  rule hasbase(list(.List), Base) => false

  rule invokeBuiltin(obj("get_attr",_), ListItem(Self) ListItem(Instance) ListItem(Owner), .) => describe(Self, Instance, Owner, "get_attr")
  rule invokeBuiltin(obj("set_attr",_), ListItem(Self) ListItem(Instance) ListItem(Value), .) => doCall(getref(Self, "__set__"), ListItem(Self) ListItem(Instance) ListItem(Value), .)
  rule invokeBuiltin(obj("set_ref_default",_), ListItem(Self) ListItem(Instance) ListItem(Value), .) => setref(id(Instance), getattr(Self, "__get__"), Value) ~> ref("None")
  rule invokeBuiltin(obj("set_attr_string",_), ListItem(Self) ListItem(Instance) ListItem(Value), .) => test(istype(Value, ref("str")), setattr(id(Instance), getattr(Self, "__get__"), getattr(Value, "__value__")), raiseInternal("TypeError", getattr(Self, "__get__") +String " must be set to a string object")) ~> ref("None")
  rule doDescribe(Self, .Obj, _, "get_attr") => Self
  rule doDescribe(Self, O:Object, _, "get_attr") => getattr(O, getattr(Self, "__get__"))

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

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at most " +String Int2String(I) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when I >=Int 0 andBool N =/=Int I andBool ((T andBool lengthList L -Int 1 >Int I) orBool ((notBool T) andBool lengthList L >Int I))

  context list(.) ~> iterate(HOLE,_)

  rule iterate(O, K) => try: (list(.) ~> iterate(ref("iter") (O, .Arguments), K)) except ref("TypeError") : test(K ==K ., raise, K) else: pass
  rule list(L:List) ~> iterate(O:Object, K) => try: addItem(getmember(O, "__next__", true, false, false) (.Arguments)) except ref("StopIteration") : list(L) else: (list(L) ~> iterate(O, K))
  rule (addItem(O:Object) => .) ~> popx ~> list(_ (. => ListItem(O)))
  rule Lbl:KLabel(Kl:KList) ~> setx(K2)  => setx(K2) ~> Lbl(Kl) when isKResult(Lbl(Kl))
  rule Lbl:KLabel(Kl:KList) ~> popx => popx ~> Lbl(Kl) when isKResult(Lbl(Kl))

  rule <k> mapping(O, K) => iterate(getmember(O, "keys", true, false, false) (.Arguments) -> K, raiseInternal("TypeError", "o.keys() are not iterable")) ~> map(.) ~> mapping(O, K) ...</k>
  rule <k> list((ListItem(O2:Object) => .) _) ~> (. => addPair(O2, (O [ O2 ]))) ~> map(_) ~> mapping(O,_) ...</k>
  rule <k> list(_) ~> (addPair(O:Object, O2:Object) => .) ~> map(_ (. => O |-> O2)) ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> (mapping(_,_) => .) ...</k>
  context list(_) ~> addPair(_, HOLE) ~> map(_)

  rule <k> newHelper(O:Object, Type:Object, St:Set) => test(hasbase(O, Type), test(id(O) in lookup(Sym, St), raiseInternal("TypeError", "unsafe builtin __new__ call error message"), .), raiseInternal("TypeError", "invalid builtin __new__ call argument type error message")) ...</k>
       <symbols> Sym:Map </symbols>

  rule raiseInternal(S, O) => raise mutable("args" |-> undefined(strvalue(O)),ref(S))

  rule <k> executeModule(CO:Object, Builtins:Object, Dict:Object) => (Dict [ "__name__"], .Expressions := CO . String2Id("co_name")) ~> (Dict [ "__doc__" ], .Expressions := CO . String2Id("co_consts") [0]) ~> (Dict [ "__builtins__" ], .Expressions := Builtins) ~> setref(id(CO), "co_names", (getref(CO, "co_varnames") + getref(CO, "co_cellvars") + getref(CO, "co_names"))) ~> setref(id(CO), "co_varnames", tuple(.Expressions)) ~> setref(id(CO), "co_cellvars", tuple(.Expressions)) ~> executeFrame(N:Int +Int 1, ref(id(CO)), ref("None"), Dict, Dict, Builtins, {.KeyData}, .) ...</k>
       <nextLoc> N => N +Int 2 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> ref(id(Dict)) "__class__" |-> ref("module") </oattrs>
       ...</object>) [allocation]


  rule <k> makeFrame(N, CO:Object, Back:Object, Locals:Object, Globals:Object, Builtins:Object, Cells:Object, Args:Map) => setref(N, "f_code", CO) ~> setref(N, "f_back", Back) ~> setref(N, "f_locals", Locals) ~> setref(N, "f_globals", Globals) ~> test(istype(Builtins, ref("module")), setref(N, "f_builtins", Builtins . String2Id("__dict__")), setref(N, "f_builtins", Builtins)) ~> setref(N, "f_cells", Cells)  ~> setArgs(N, Args) ...</k>
       (. => <object>...
         <id>N</id>
         <oattrs> "__class__" |-> ref("frame") </oattrs>
       ...</object>) [allocation]

  rule [executeFrame]: <k> executeFrame(N, CO:Object, Back:Object, Locals:Object, Globals:Object, Builtins:Object, Cells:Object, Args:Map) => makeFrame(N, CO, Back, Locals, Globals, Builtins, Cells, Args) ~> getattr(CO, "co_code") ...</k>
       <frameObject> _ => N </frameObject>

  rule (. => doBind(Id2String(X), B, ref(N))) ~> setArgs(N, (X |-> ref(B) => .) _)
  rule [dissolve-setArgs]: setArgs(_, .) => .

  rule <k> describe(Self, Instance, Owner, S) => doDescribe(Self, Instance, gettype(Instance), S) ...</k>
       <symbols>... "None" |-> NoneId ...</symbols> when id(Owner) ==K NoneId orBool id(Instance) =/=K NoneId

  rule <k> describe(Self, Instance, Owner, S) => doDescribe(Self, .Obj, Owner, S) ...</k>
       <symbols>... "None" |-> NoneId ...</symbols> when id(Owner) =/=K NoneId andBool id(Instance) ==K NoneId

endmodule
