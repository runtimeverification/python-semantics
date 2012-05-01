module PYTHON-SEMANTICS-COMMON
  imports PYTHON-SYNTAX
  imports PYTHON-SEMANTICS-LOGIC
  imports PYTHON-SEMANTICS-SYNTAX

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
                  <debug> $DEBUG:Bool </debug>
                  <hashInfo> $HASHINFO:List </hashInfo>
                </T>

  syntax K ::= "initialize" "(" K ")"
             | "bind" "(" NAME "," Builtin ")" 
             | "unbind" "(" NAME ")"
             | "mapping" "(" Expression "," K ")" [:strict(1):]
             | "addItem" "(" Expression ")" [:strict:]
             | "addPair" "(" Builtin "," Expression ")" [:strict(2):]
             | "popx"
             | "setx" "(" K ")"
             | "newHelper" "(" Expression "," Expression "," Set ")" [:strict(1 2):]
             | "raiseInternal" "(" String "," Expression ")" [:strict(2):]
             | "setattr" "(" Builtin "," String "," K ")"
             | "setref" "(" Builtin "," String "," Expression ")" [:strict(3):]
             | "executeModule" "(" Expression "," Expression "," Expression ")" [:strict:]
             | "executeFrame" "(" Nat "," Expression "," Expression "," Expression "," Expression "," Expression "," Expression "," Map ")" [:strict(2 3 4 5 6 7):]
             | "setArgs" "(" Map ")"

  syntax Test ::= "istype" "(" Expression "," Expression ")" [:strict:]
                | "hasbase" "(" Expression "," Expression ")" [:strict:]
                | "hasbase" "(" ListRef "," Expression ")"

  syntax ObjRef ::= "ref" "(" String ")"
                  | "ref" "(" K ")"
                  | "builtin" "(" Id ")"
                  | "gettype" "(" Expression ")"
                  | "getbases" "(" Expression ")"
                  | "getmember" "(" Expression "," Id "," Bool "," Bool "," Bool ")" [:strict(1):] 
                  | "binaryOp" "(" Expression "," Expression "," String "," String "," K ")" [:strict(1 2):]
                  | "unaryOp" "(" Expression "," String "," K ")" [:strict(1):]
                  | "invoke" "(" Expression "," Map ")" [:strict(1):]
                  | "invokeBuiltin" "(" Expression "," List "," Map ")" [:strict(1):]
                  | "invokeFunction" "(" Expression "," List "," Map ")" [:strict(1):]
                  | "doCall" "(" Expression "," List "," Map ")"
                  | "mutable" "(" Value "," Expression ")" [:strict(2):]
                  | "mutable" "(" Map "," Expression ")" [:strict(2):]
                  | "immutable" "(" Value "," Expression ")" [:strict(2):]
                  | "copy" "(" Expression "," Expression ")" [:strict:]
                  | "name" "(" Expression ")"
                  | "codeObject" "(" Id "," Parameters "," K ")"

  syntax ListRef ::= "iterate" "(" Expression "," K ")" [:strict(1):]

  macro name(E) = getmember(E, String2Id("__name__"), true, false, true)

  context doCall(HOLE, _, _) when HOLE =/=K .

  syntax String ::= "docString" "(" K ")" [:function:]
  define docString(S ;) => S
  define docString(S ; newline _) => S
  define docString(_) => ref("None")

  syntax Map ::= "Env2Dict" "(" Map ")" [:function:]
  define Env2Dict((X |-> K M)) => Id2String(X) |-> K Env2Dict(M)
  define Env2Dict(.) => .

  syntax Nat ::= "lengthMap" Map [:function:]
  define lengthMap(_ |-> _ M:Map) => 1 +Int lengthMap M
  define lengthMap . => 0

  syntax Set ::= "Ids2Strings" "(" Set ")" [:function:]
  define Ids2Strings(SetItem(X) St) => SetItem(Id2String(X)) Ids2Strings(St)
  define Ids2Strings(.) => .

  syntax List ::= "Listify" "(" K ")" [:function:]
  define Listify((P:Parameter , Ps:Parameters)) => ListItem(P) Listify(Ps)
  define Listify(.Parameters) => .

  syntax Parameters ::= "DeListify" "(" List ")" [:function:]
  define DeListify(ListItem(P) L) => P , DeListify(L)
  define DeListify(.) => .Parameters

  syntax List ::= "Idify" "(" List ")" [:function:]
  define Idify(ListItem(O) L) => ListItem(id(O)) Idify(L)
  define Idify(.) => .

  syntax Set ::= "Setify" "(" List ")" [:function:]
  define Setify(ListItem(K) L) => SetItem(K) Setify(L)
  define Setify(.) => .

  syntax List ::= "DeSetify" "(" Set ")" [:function:]
  define DeSetify(SetItem(K) St) => ListItem(K) DeSetify(St)
  define DeSetify(.) => .

  syntax List ::= "sorted" "(" List ")" [:function:]
  define sorted(ListItem(K) L) => sorted(less(L, K)) ListItem(K) sorted(more(L, K))
  define sorted(.) => .

  syntax List ::= "less" "(" List "," K ")" [:function:]
  define less((ListItem(K) L), K2:K) => ListItem(K) less(L, K2) when lt(K, K2)
  define less((ListItem(K) L), K2) => less(L, K2) when notBool lt(K, K2)
  define less(.,_) => .

  syntax List ::= "more" "(" List "," K ")" [:function:]
  define more((ListItem(K) L), K2) => ListItem(K) more(L, K2) when notBool lt(K, K2)
  define more((ListItem(K) L), K2) => more(L, K2) when lt(K, K2)
  define more(.,_) => .

  syntax Bool ::= "lt" "(" K "," K ")" [:function:]
  define lt(S, I) => true
  define lt(I, S) => false
  define lt(S, S2) => S <String S2
  define lt(I, I2:Int) => I <Int I2

  syntax Set ::= "lookup" "(" Map "," Set ")" [:function:]
  define lookup((K |-> K2 M), (SetItem(K) St)) => SetItem(K2) lookup(M, St)
  define lookup(_, .) => .

  syntax Map ::= "Mapify" "(" KeyData ")" [:function:]
  define Mapify((K : K2 , KD:KeyData)) => K |-> K2 Mapify(KD)
  define Mapify(.KeyData) => .

  syntax KeyData ::= "DeMapify" "(" Map ")" [:function:]
  define DeMapify((K |-> K2 M)) => (K : K2) , DeMapify(M)
  define DeMapify(.) => .List{","}

  syntax Builtin ::= "id" "(" Expression ")" [:function:]
  define id(obj(B,_)) => B
  define id(undefined(S)) => undefined(S)

  syntax Int ::= "intvalue" "(" Expression ")" [:function:]
  define intvalue(obj(_,<oattrs>... "__value__" |-> I:Int ...</oattrs>)) => I

  syntax String ::= "strvalue" "(" Object ")" [:function:]
  define strvalue(obj(_,<oattrs>... "__value__" |-> S:String ...</oattrs>)) => S

  syntax List ::= "listvalue" "(" Object ")" [:function:]
  define listvalue(obj(_,<oattrs>... "__value__" |-> list(L:List) ...</oattrs>)) => L

  syntax Map ::= "mapvalue" "(" Object ")" [:function:]
  define mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ _ |-> list(_ (ListItem(K : K2) => .) _)) ...</oattrs>)) (. => K |-> K2)
  define mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>))
  define mapvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => .

  syntax K ::= "get" "(" List "," Int ")" [:function:]
  define get(ListItem(K) _, 0) => K
  define get(ListItem(_) L, N) => get(L, N -Int 1)

  syntax List ::= "getl" "(" K ")" [:function:]
  define getl(list(L)) => L

  syntax K ::= "getattr" "(" Expression "," String ")" [:function:]
  define getattr(obj(_,<oattrs> Attrs:Map </oattrs>), S:String) => Attrs(S)
  context getattr(HOLE,_)

  syntax K ::= "getref" "(" Expression "," String ")" [:function:]
  define getref(obj(_,<oattrs> Attrs </oattrs>), S) => ref(Attrs(S))
  context getref(HOLE,_)

  syntax Set ::= Set "&Set" Set [:function:]
  define St1:Set &Set St2:Set => St1 -Set (St1 -Set St2)

  syntax Set ::= "values" Map [:function:]
  define values (K |-> K2 M) => SetItem(K2) values M
  define values . => .

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

  macro gettype(E:Expression) = getref(E, "__class__")
  macro getbases(E) = getattr(E, "__bases__")

  //TODO: subclasshook
  rule istype(O:Object, Type:Object) => hasbase(gettype(O), Type)

  //needs predicates to work without obj()
  rule hasbase(obj(N:Nat,ObjState:Bag), Base:Object) => or(obj(N,ObjState) ==K Base, hasbase(getbases(obj(N,ObjState)), Base))

  rule hasbase(list(ListItem(N) L), Base) => or(hasbase(ref(N), Base),hasbase(list(L), Base))
  rule hasbase(list(.List), Base) => false

  rule <k> invokeBuiltin(obj("get_ref",_), ListItem(obj(_, <oattrs>... "__get__" |-> S ...</oattrs>)) ListItem(O) ListItem(_), .) => getref(O, S) ...</k>
  rule <k> invokeBuiltin(obj("get_attr",_), ListItem(obj(_, <oattrs>... "__get__" |-> S ...</oattrs>)) ListItem(O) ListItem(_), .) => getattr(O, S) ...</k>

  rule <k> ref(S) => ref(N) ...</k>
       <symbols>... S |-> N ...</symbols>

  rule <k> ref(S) => obj(S2:String,<oattrs>Attrs</oattrs>) ...</k>
       <symbols>... S |-> S2 ...</symbols>
       <object>...
         <id>S2</id>
         <oattrs>Attrs</oattrs>
       ...</object>

 rule <k> ref(N) => obj(N,<oattrs>Attrs</oattrs>) ...</k>
       <object>...
         <id>N</id>
         <oattrs>Attrs</oattrs>
       ...</object>

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> N "__method__" |-> T:Bool ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when (T andBool lengthList L -Int 1 =/=Int N) orBool ((notBool T) andBool lengthList L =/=Int N)

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at least " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when N =/=Int I andBool ((T andBool lengthList L -Int 1 <Int N) orBool ((notBool T) andBool lengthList L <Int N))

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at most " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when I >=Int 0 andBool N =/=Int I andBool ((T andBool lengthList L -Int 1 >Int I) orBool ((notBool T) andBool lengthList L >Int I))

  context list(.) ~> iterate(HOLE,_)

  rule iterate(O, K) => try: (list(.) ~> iterate(ref("iter") (O), K)) except ref("TypeError") : test(K ==K ., raise, K) else: pass
  rule list(L) ~> iterate(O, K) => try: addItem(getmember(O,  String2Id("__next__"), true, false, false) ()) except ref("StopIteration") : list(L) else: (list(L) ~> iterate(O, K))
  rule (addItem(O) => .) ~> popx ~> list(_ (. => ListItem(O)))
  rule K ~> setx(K2) => setx(K2) ~> K when 'isKResult(K)
  rule K ~> popx => popx ~> K when 'isKResult(K)

  rule <k> mapping(O, K) => iterate(getmember(O, String2Id("keys"), true, false, false) () -> K, raiseInternal("TypeError", "o.keys() are not iterable")) ~> map(.) ~> mapping(O, K) ...</k>
  rule <k> list((ListItem(B:Builtin) => .) _) ~> (. => addPair(B, (O [ ref(B) ]))) ~> map(_) ~> mapping(O,_) ...</k>
  rule <k> list(_) ~> (addPair(B, O) => .) ~> map(_ (. => B |-> O)) ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> (mapping(_,_) => .) ...</k>

  rule <k> newHelper(O, Type, St:Set) => test(hasbase(O, Type), test(id(O) in lookup(Sym, St), raiseInternal("TypeError", "unsafe builtin __new__ call error message"), .), raiseInternal("TypeError", "invalid builtin __new__ call argument type error message")) ...</k>
       <symbols> Sym:Map </symbols>

  rule raiseInternal(S, O) => raise mutable("args" |-> undefined(strvalue(O)),ref(S))

  rule <k> executeModule(CO:Object, Builtins:Object, Dict:Object) => ((Dict [ "__name__"]) , .Expressions) := CO . String2Id("co_name") ~> ((Dict [ "__doc__" ]) , .Expressions) := CO . String2Id("co_consts") [0] ~> ((Dict [ "__builtins__" ]) , .Expressions) := Builtins ~> setref(id(CO), "co_names", (getref(CO, "co_varnames") + getref(CO, "co_cellvars") + getref(CO, "co_names"))) ~> setref(id(CO), "co_varnames", tuple()) ~> setref(id(CO), "co_cellvars", tuple()) ~> executeFrame(N +Int 1, ref(id(CO)), ref("None"), Dict, Dict, Builtins, {}, .) ...</k>
       <nextLoc> N => N +Int 2 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> id(Dict) "__class__" |-> Module </oattrs>
       ...</object>)
       <symbols>... "module" |-> Module:Nat ...</symbols>


  rule <k> executeFrame(N, CO:Object, Back:Object, Locals:Object, Globals:Object, Builtins:Object, Cells:Object, Args:Map) => setref(N, "f_code", CO) ~> setref(N, "f_back", Back) ~> setref(N, "f_locals", Locals) ~> setref(N, "f_globals", Globals) ~> test(istype(Builtins, ref("module")), setref(N, "f_builtins", Builtins . String2Id("__dict__")), setref(N, "f_builtins", Builtins)) ~> setref(N, "f_cells", Cells) ~> setArgs(Args) ~> getattr(CO, "co_code") ...</k>
       <currentFrame> _ => N </currentFrame>
       (. => <object>...
         <id>N</id>
         <oattrs> "__class__" |-> Frame </oattrs>
       ...</object>)
       <symbols>... "frame" |-> Frame:Nat ...</symbols>

  rule (. => (X:Id, .Expressions) := ref(B)) ~> setArgs((X |-> B => .) _)
  rule setArgs(.) => .

end module
