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
                  <gc> 1 </gc>
                  <gcThreshold> $GCTHRESHOLD:Int </gcThreshold>
                  <literals> .Map </literals>
                  <symbols> .Map </symbols>
                  <builtinModules> .Map </builtinModules>
                  <references> .Map </references>
                  <bootstrapping> 3 </bootstrapping>
                  <nextLoc> 1 </nextLoc>
                  <sysPath> $SYSPATH:List </sysPath>
                  <environ> $ENVIRON:Map </environ>
                  <constants> $CONSTANTS:Map </constants>
                  <importlib> $IMPORTLIB:K </importlib>
                </T>

  syntax K ::= "initialize" "(" K ")"
             | "bind" "(" NAME "," Exp ")" 
             | "unbind" "(" NAME ")"
             | "mapping" "(" Exp "," K ")" [strict(1)]
             | "addItem" "(" Exp ")" [strict]
             | "addPair" "(" Exp "," Exp ")"
             | "popx"
             | setx(K)
             | savetb(Exp) [strict]
             | "newHelper" "(" Exp "," Exp "," Set ")" [strict(1, 2)]
             | "raiseInternal" "(" String "," Exp ")" [strict(2)]
             | "setattr" "(" ObjId "," String "," K ")"
             | "setref" "(" ObjId "," String "," Exp ")" [strict(3)]
             | "setenv" "(" ObjId "," Exp "," Exp ")" [strict(2, 3)]
             | "executeModule" "(" Exp "," Exp "," Exp ")" [strict]
             | executeFrame(Int, Exp, Exp, Exp, Exp, Exp, Exp, Map) [strict(2, 3, 4, 5, 6, 7)]
             | makeFrame(Int, Exp, Exp, Exp, Exp, Exp, Exp, Map) [strict(2, 3, 4, 5, 6, 7)]
             | setArgs(Int, Map)
             | getMro(Exp, Exp) [strict]
             | doBind(String, Exp, Exp) [strict(3)]

  syntax Test ::= "istype" "(" Exp "," Exp ")" [strict]
                | "hasbase" "(" K "," Exp ")" [strict]

  // TODO: figure out why the good goddamn fuck it is that if I make ref(K) of sort ObjRef then parsing dicts takes exponential time.
  syntax Exp ::= "ref" "(" K ")"
                  | "builtin" "(" Id ")"
                  | "gettype" "(" Exp ")"
                  | "getbases" "(" Exp ")"
                  | "getmember" "(" Exp "," Exp "," Bool "," Bool "," Bool ")" [strict(1, 2)] 
                  | "setmember" "(" Exp "," Exp "," Exp ")" [strict] 
                  | "binaryOp" "(" Exp "," Exp "," String "," String "," K ")" [strict(1, 2)]
                  | "unaryOp" "(" Exp "," String "," K ")" [strict(1)]
                  | "invoke" "(" Exp "," Map ")" [strict(1)]
                  | "invokeBuiltin" "(" Exp "," List "," Map ")" [strict(1)]
                  | "invokeFunction" "(" Exp "," List "," Map ")" [strict(1)]
                  | "doCall" "(" Exp "," List "," Map ")"
                  | "mutable" "(" Value "," Exp ")" [strict(2)]
                  | "mutable" "(" Map "," Exp ")" [strict(2)]
                  | "immutable" "(" Value "," Exp ")" [strict(2)]
                  | "immutable" "(" Map "," Exp ")" [strict(2)]
                  | "name" "(" Exp ")"
                  | "codeObject" "(" Id "," Parameters "," K "," Bool ")"
                  | "class" "(" Arguments "," Exp ")" [strict]
                  | describe(Exp, Exp, Exp, String) [strict(1, 2, 3)]
                  | doDescribe(Exp, Exp, Exp, String) [strict(1, 2, 3)]
                  | reduce(Exp, K, KLabel) [strict(1)]
                  | reduce(List, K, KLabel)

  syntax K ::= "iterate" "(" Exp "," K ")" [strict(1)]

  rule name(E) => getmember(E, "__name__", true, false, true) [macro]

  context doCall(HOLE, _, _) when HOLE =/=K .

  rule (. => iterate(O, .)) ~> reduce(O:Object, _, _)
  rule list(L:List) ~> reduce(_, K, Lbl:KLabel) => reduce(L, K, Lbl)
  rule reduce(.List, K, _) => K
  rule reduce(ListItem(I) L:List, K, Lbl) => Lbl(I,,reduce(L, K, Lbl))

  syntax String ::= "docString" "(" K ")" [function]
  rule docString(S:String ;) => S 
  rule docString(S:String ; newline _) => S 
  rule docString(Lbl:KLabel(_)) => ref("None") when Lbl =/=KLabel '_newline_ andBool Lbl =/=KLabel 'Expr 
  rule docString(Lbl:KLabel(Lbl2:KLabel(_),,_)) => ref("None") when Lbl ==KLabel '_newline_ andBool Lbl2 =/=KLabel 'Expr
  rule docString(Lbl:KLabel(Lbl2:KLabel(K),,_)) => ref("None") when Lbl ==KLabel '_newline_ andBool Lbl2 ==KLabel 'Expr andBool isString(K) =/=K true 
  rule docString(Lbl:KLabel(K,,_)) => ref("None") when Lbl ==KLabel 'Expr andBool isString(K) =/=K true 
  rule docString(.) => ref("None") 

  syntax Map ::= "Env2Dict" "(" Map ")" [function]
  rule Env2Dict((X |-> K M)) => Id2String(X) |-> K Env2Dict(M) 
  rule Env2Dict(.) => . 

  syntax Int ::= "lengthMap" Map [function]
  rule lengthMap(_ |-> _ M:Map) => 1 +Int lengthMap M 
  rule lengthMap . => 0 

  syntax Set ::= "Ids2Strings" "(" Set ")" [function]
  rule Ids2Strings(SetItem(X) St) => SetItem(Id2String(X)) Ids2Strings(St) 
  rule Ids2Strings(.) => . 

  syntax List ::= "Listify" "(" K ")" [function]
  rule Listify(((P)::Parameter , (Ps)::Parameters)) => ListItem(P) Listify(Ps) 
  rule Listify(.Parameters) => . 

  syntax Exps ::= "DeListify" "(" List ")" [function]
  rule DeListify(ListItem(P) L) => (P)::Parameter , DeListify(L) 
  rule DeListify(.) => .Exps 

  syntax List ::= "Refify" "(" List ")" [function]
  rule Refify(ListItem(O) L) => ListItem(ref(O)) Refify(L) 
  rule Refify(.) => . 

  syntax List ::= "Idify" "(" List ")" [function]
  rule Idify(ListItem(O) L) => ListItem(id(O)) Idify(L) 
  rule Idify(.) => . 

  syntax Set ::= "Setify" "(" List ")" [function]
  rule Setify(ListItem(K) L) => SetItem(K) Setify(L) 
  rule Setify(.) => . 

  syntax List ::= "DeSetify" "(" Set ")" [function]
  rule DeSetify(SetItem(K) St) => ListItem(K) DeSetify(St) 
  rule DeSetify(.) => . 

  syntax List ::= "sorted" "(" List ")" [function]
  rule sorted(ListItem(K) L) => sorted(less(L, K)) ListItem(K) sorted(more(L, K)) 
  rule sorted(.) => . 

  syntax List ::= "less" "(" List "," K ")" [function]
  rule less((ListItem(K) L), K2:K) => ListItem(K) less(L, K2) when lt(K, K2) 
  rule less((ListItem(K) L), K2) => less(L, K2) when notBool lt(K, K2) 
  rule less(.,_) => . 

  syntax List ::= "more" "(" List "," K ")" [function]
  rule more((ListItem(K) L), K2) => ListItem(K) more(L, K2) when notBool lt(K, K2) 
  rule more((ListItem(K) L), K2) => more(L, K2) when lt(K, K2) 
  rule more(.,_) => . 

  syntax Bool ::= "lt" "(" K "," K ")" [function]
  rule lt(S:String, I:Int) => true 
  rule lt(I:Int, S:String) => false 
  rule lt(S:String, S2:String) => S <String S2 
  rule lt(I:Int, I2:Int) => I <Int I2 

  syntax Set ::= "lookup" "(" Map "," Set ")" [function]
  rule lookup((K |-> K2 M), (SetItem(K) St)) => SetItem(K2) lookup(M, St) 
  rule lookup(_, .) => . 

  syntax Map ::= "Mapify" "(" KeyData ")" [function]
  rule Mapify((K : K2 , KD:KeyData)) => K |-> K2 Mapify(KD) 
  rule Mapify(.KeyData) => . 

  syntax KeyData ::= "DeMapify" "(" Map ")" [function]
  rule DeMapify((K |-> K2 M)) => (K : K2) , DeMapify(M) 
  rule DeMapify(.) => .NAMES 

  syntax ObjId ::= "id" "(" Exp ")" [function]
  rule id(obj(B,_)) => B
  rule id(ref(B)) => B

  syntax Int ::= "intvalue" "(" Exp ")" [function]
  rule intvalue(obj(_,<oattrs>... "__value__" |-> I:Int ...</oattrs>)) => I 

  syntax Float ::= "floatvalue" "(" Exp ")" [function]
  rule floatvalue(obj(_,<oattrs>... "__value__" |-> F:Float ...</oattrs>)) => F 

  syntax String ::= "strvalue" "(" Object ")" [function]
  rule strvalue(obj(_,<oattrs>... "__value__" |-> S:String ...</oattrs>)) => S 

  syntax List ::= "listvalue" "(" Object ")" [function]
  rule listvalue(obj(_,<oattrs>... "__value__" |-> list(L:List) ...</oattrs>)) => L 

  syntax Map ::= "mapvalue" "(" Object ")" [function]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(_ (ListItem((K : K2)::KeyDatum) => .)) _)) ...</oattrs>)) (. => K |-> K2)  [anywhere]
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>)) 
  rule mapvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => . 

  syntax List ::= setvalue(Object) [function]
  rule setvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(_ (ListItem(K) => .)) _)) ...</oattrs>)) (.List => ListItem(K)) [anywhere]
  rule setvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>)) 
  rule setvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => . 

  syntax K ::= "get" "(" List "," Int ")" [function]
  rule get(ListItem(K) _, 0) => K 
  rule get(ListItem(_) L, N) => get(L, N -Int 1) when N >Int 0 

  syntax List ::= "get" "(" List "," Int "," Int ")" [function]
  rule get(ListItem(_) L, Start:Int, End:Int) => get(L, Start -Int 1, End -Int 1) when Start >Int 0
  rule get(ListItem(K) L, 0, End) => ListItem(K) get(L, 0, End -Int 1) when End >Int 0
  rule get(_, 0, 0) => .List

  syntax List ::= "getl" "(" K ")" [function]
  rule getl(list(L)) => L 

  syntax K ::= "getattr" "(" Exp "," K ")" [function]
  rule getattr(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => Attrs:Map(S) 

  syntax K ::= "getattr2" "(" Exp "," String ")" [strict(1)]
  rule getattr2(O:Object, S:String) => getattr(O, S)

  syntax ObjRef ::= "getref" "(" Exp "," String ")" [function]
  rule getref(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => Attrs:Map(S) 

  syntax Bool ::= hasattr(Object, String) [function]
  rule hasattr(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => S in keys Attrs

  syntax ObjRef ::= "getref2" "(" Exp "," String ")" [strict(1)]
  rule getref2(O:Object, S:String) => getref(O, S)

  syntax Set ::= Set "&Set" Set [function]
  rule St1:Set &Set St2:Set => St1 -Set (St1 -Set St2) 

  syntax Bool ::= "all" "(" List "," KLabel ")" [function]
  rule all(ListItem(K) L:List, Lbl:KLabel) => Lbl(K) andBool all(L, Lbl) 
  rule all(., _) => true 

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

  syntax K ::= finally(K, CurrentFrameCellFragment, List, List, List, K)
             | call(K, CurrentFrameCellFragment, List, K, K)
             | generator(K, CurrentFrameCellFragment, List, K, K, K)

  rule binaryOp(O, O2:Object, S, S2, K:K) => test(and(istype(O, ref(S)), istype(O2, ref(S2))), K, ref("NotImplemented"))
  rule unaryOp(O, S, K) => test(istype(O, ref(S)), K, ref("NotImplemented"))

  rule gettype(E:Exp) => getref(E, "__class__") [macro]
  rule getbases(E) => getattr2(getref2(E, "__bases__"), "__value__") [macro]

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
  rule doDescribe(obj(_,<oattrs>... "__get__" |-> S:String ...</oattrs>), O:Object, _, "get_attr") => getattr(O, S)
  rule doDescribe(obj(_,<oattrs>... "__get__" |-> S:String[I:Int] ...</oattrs>), O:Object, _, "get_attr") => get(getl(getattr(O, S)), I)
  rule doDescribe(obj(_,<oattrs>... "__get__" |-> ref(S:String)[I:Int] ...</oattrs>), O:Object, _, "get_attr") => getattr(O, S)[I]

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

  rule iterate(O:Object, K) => try: (list(.) ~> iterate(ref("iter") (O), K)) except ref("TypeError") : test(K ==K ., raise, K) else: pass
  rule list(L:List) ~> iterate(O:Object, K) => try: addItem(getmember(O, "__next__", true, false, false) (.Arguments)) except ref("StopIteration") : list(L) else: (list(L) ~> iterate(O, K))
  rule (addItem(O:Object) => .) ~> popx ~> list(_ (. => ListItem(O)))
  rule Lbl:KLabel(Kl:KList) ~> setx(K2)  => setx(K2) ~> Lbl(Kl) when isKResult(Lbl(Kl))
  rule Lbl:KLabel(Kl:KList) ~> popx => popx ~> Lbl(Kl) when isKResult(Lbl(Kl))

  rule <k> mapping(O, K) => iterate(getmember(O, "keys", true, false, false) (.Arguments) -> K, raiseInternal("TypeError", "o.keys() are not iterable")) ~> map(.) ~> mapping(O, K) ...</k>
  rule <k> iterate(.Obj, _) ~> map(.) ~> mapping(_, _) => .Obj ...</k>
  rule <k> list((ListItem(O2:Object) => .) _) ~> (. => addPair(O2, (O [ O2 ]))) ~> map(_) ~> mapping(O,_) ...</k>
  rule <k> list(_) ~> (addPair(O:Object, O2:Object) => .) ~> map(_ (. => O |-> O2)) ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> (mapping(_,_) => .) ...</k>
  context list(_) ~> addPair(_, HOLE) ~> map(_)

  rule <k> newHelper(O:Object, Type:Object, St:Set) => test(hasbase(O, Type), test(id(O) in lookup(Sym, St), raiseInternal("TypeError", "unsafe builtin __new__ call error message"), .), raiseInternal("TypeError", "invalid builtin __new__ call argument type error message")) ...</k>
       <symbols> Sym:Map </symbols>

  syntax K ::= keywordHelper(String, Map, Set)
  rule keywordHelper(Name, M, S) => #if keys(M) -Set S =/=Set . #then raiseInternal("TypeError", Name +String "does not take keyword arguments") #else . #fi

  syntax K ::= raiseInternal(String, String, Exp) [strict(3)]
  rule raiseInternal(S, O:Object) => raiseInternal(S, strvalue(O), tuple(?Msg:String))
  rule raiseInternal(S, O, Msg:Object) => raise mutable("args" |-> Msg "msg" |-> O,ref(S))

  rule <k> executeModule(CO:Object, Builtins:Object, Dict:Object) => (Dict [ "__name__"] = (CO . String2Id("co_name"))::Exp) ~> (Dict [ "__doc__" ] = (CO . String2Id("co_consts") [0])::Exp) ~> (Dict [ "__builtins__" ] = Builtins) ~> setref(id(CO), "co_names", (getref(CO, "co_varnames") + getref(CO, "co_cellvars") + getref(CO, "co_names"))) ~> setref(id(CO), "co_varnames", tuple(.Exps)) ~> setref(id(CO), "co_cellvars", tuple(.Exps)) ~> ref("sys") . String2Id("modules")[CO . String2Id("co_name")] = ref(N) ~> executeFrame(N:Int +Int 1, ref(id(CO)), ref("None"), Dict, Dict, Builtins, {.KeyData}, .) ...</k>
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

  rule (. => doBind(Id2String(X), ref(B), ref(N))) ~> setArgs(N, (X |-> ref(B) => .) _)
  rule [dissolve-setArgs]: setArgs(_, .) => .

  rule <k> describe(Self, Instance, Owner, S) => doDescribe(Self, Instance, gettype(Instance), S) ...</k>
       <symbols>... "None" |-> NoneId ...</symbols> when id(Owner) ==K NoneId orBool id(Instance) =/=K NoneId

  rule <k> describe(Self, Instance, Owner, S) => doDescribe(Self, .Obj, Owner, S) ...</k>
       <symbols>... "None" |-> NoneId ...</symbols> when id(Owner) =/=K NoneId andBool id(Instance) ==K NoneId

  syntax Exp ::= "#if" Bool "#then" Exp "#else" Exp "#fi" [function]
endmodule
