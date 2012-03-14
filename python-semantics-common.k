module PYTHON-SEMANTICS-COMMON
  imports PYTHON-SYNTAX
  imports PYTHON-SEMANTICS-LOGIC
  imports PYTHON-SEMANTICS-SYNTAX

  configuration <T>
                  <k> initialize ~> #id "__name__" := "__main__" ~> #id "__doc__" := docString($PGM) ~> $PGM:K </k>
                  <control>
                    <xstack> .List </xstack>
                    <xcontext> ref("None") </xcontext>
                    <currentBlock> 0 </currentBlock>
                    <lstack> .List </lstack>
                    <fstack> .List </fstack>
                  </control>
                  <blocks>
                    <block multiplicity="+">
                      <env> .Map </env>
                      <blockId> 0 </blockId>
                      <parentBlock> .K </parentBlock>
                      <globals> .Set </globals>
                      <nonlocals> .Set </nonlocals>
                      <isClass> false </isClass>
                    </block>
                  </blocks>
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
                </T>

  syntax K ::= "initialize"
             | "bind" "(" NAME "," Builtin ")" 
             | "doBind" "(" NAME "," Builtin "," #Bool ")" 
             | "doNonlocalBind" "(" NAME "," Builtin "," #Int "," #Bool ")"
             | "unbind" "(" NAME ")"
             | "iterate" "(" Expression "," K ")" [:strict(1):]
             | "mapping" "(" Expression "," K ")" [:strict(1):]
             | "addItem" "(" Expression ")" [:strict:]
             | "addPair" "(" Builtin "," Expression ")" [:strict(2):]
             | "popx"
             | "setx" "(" K ")"
             | "newHelper" "(" Expression "," Expression "," Set ")" [:strict(1 2):]
             | "raiseInternal" "(" #String "," #String ")"

  syntax Test ::= "istype" "(" Expression "," Expression ")" [:strict:]
                | "hasbase" "(" Expression "," Expression ")" [:strict:]
                | "hasbase" "(" ListRef "," Expression ")"

  syntax ObjRef ::= "ref" "(" #String ")"
                  | "ref" "(" K ")"
                  | "builtin" "(" #Id ")"
                  | "gettype" "(" Expression ")"
                  | "getbases" "(" Expression ")"
                  | "getmember" "(" Expression "," #Id "," #Bool "," #Bool "," #Bool ")" [:strict(1):] 
                  | "binaryOp" "(" Expression "," Expression "," #String "," #String "," K ")" [:strict(1 2):]
                  | "unaryOp" "(" Expression "," #String "," K ")" [:strict(1):]
                  | "invoke" "(" Expression "," Map ")" [:strict(1):]
                  | "invokeBuiltin" "(" Expression "," List "," Map ")" [:strict(1):]
                  | "invokeFunction" "(" Expression "," List "," Map ")" [:strict(1):]
                  | "doCall" "(" Expression "," List "," Map ")"
                  | "mutable" "(" Value "," Expression ")" [:strict(2):]
                  | "mutable" "(" Map "," Expression ")" [:strict(2):]
                  | "immutable" "(" Value "," Expression ")" [:strict(2):]
                  | "copy" "(" Expression "," Expression ")" [:strict:]
                  | "name" "(" Expression ")"

  macro name(E) = getmember(E, #id "__name__", true, false, true)

  context doCall(HOLE, _, _) when HOLE =/=Bool .

  declare docString : K -> #String
  define docString(S ;) => S
  define docString(S ; newline _) => S
  define docString(_) => ref("None")

  declare Env2Dict : Map -> Map
  define Env2Dict(#id S |-> K M) => S |-> K Env2Dict(M)
  define Env2Dict(.) => .

  declare lengthMap_ : Map -> #Nat
  define lengthMap(_ |-> _ M:Map) => 1 +Nat lengthMap M
  define lengthMap . => 0

  declare Ids2Strings : Set -> Set
  define Ids2Strings(SetItem(#id S) St) => SetItem(S) Ids2Strings(St)
  define Ids2Strings(.) => .

  declare Listify : Parameters -> List
  define Listify(P:Parameter , Ps:Parameters) => ListItem(P) Listify(Ps)
  define Listify(.Parameters) => .

  declare IdListify : Expressions -> List
  define IdListify(O:Object , Es:Expressions) => ListItem(id(O)) IdListify(Es)
  define IdListify(.Expressions) => .

  declare Idify : List -> List
  define Idify(ListItem(O) L) => ListItem(id(O)) Idify(L)
  define Idify(.) => .

  declare Setify : List -> Set
  define Setify(ListItem(K) L) => SetItem(K) Setify(L)
  define Setify(.) => .

  declare DeSetify : Set -> List
  define DeSetify(SetItem(K) St) => ListItem(K) DeSetify(St)
  define DeSetify(.) => .

  declare sorted : List -> List
  define sorted(ListItem(K) L) => sorted(less(L, K)) ListItem(K) sorted(more(L, K)) when L =/=Bool .
  define sorted(ListItem(K)) => ListItem(K)

  declare less : List K -> List
  define less((ListItem(K) L), K2) => ListItem(K) less(L, K2) when lt(K, K2)
  define less((ListItem(K) L), K2) => less(L, K2) when notBool lt(K, K2)
  define less(.,_) => .

  declare more : List K -> List
  define more((ListItem(K) L), K2) => ListItem(K) more(L, K2) when notBool lt(K, K2)
  define more((ListItem(K) L), K2) => more(L, K2) when lt(K, K2)
  define more(.,_) => .

  declare lt : K K -> #Bool
  define lt(S, N) => true
  define lt(N, S) => false
  define lt(S, S2) => S <String S2
  define lt(N, N2:#Nat) => N <Nat N2

  declare lookup : Map Set -> Set
  define lookup((K |-> K2:K M), (SetItem(K) St)) => SetItem(K2) lookup(M, St)
  define lookup(_, .) => .

  declare Mapify : KeyData -> Map
  define Mapify(O : O2 , KD:KeyData) => O |-> O2 Mapify(KD)
  define Mapify(.KeyData) => .

  declare DeMapify : Map -> KeyData
  define DeMapify((K |-> K2 M)) => (K : K2) , DeMapify(M)
  define DeMapify(.) => .List{","}

  declare id : Object -> Builtin
  define id(obj(B,_)) => B

  declare intvalue : Expression -> #Int
  define intvalue(obj(_,<oattrs>... "__value__" |-> I:#Int ...</oattrs>)) => I

  declare strvalue : Object -> #String
  define strvalue(obj(_,<oattrs>... "__value__" |-> S:#String ...</oattrs>)) => S

  declare listvalue : Object -> List
  define listvalue(obj(_,<oattrs>... "__value__" |-> list(L:List) ...</oattrs>)) => L

  declare mapvalue : Object -> Map
  define mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ _ |-> list(_ (ListItem(K : K2) => .) _)) ...</oattrs>)) (. => K |-> K2)
  define mapvalue(obj(_,<oattrs>... "__value__" |-> map(_ (_ |-> list(.) => .)) ...</oattrs>))
  define mapvalue(obj(_,<oattrs>... "__value__" |-> map(.) ...</oattrs>)) => .

  declare get : List #Int -> K
  define get(ListItem(K) _, 0) => K
  define get(ListItem(_) L, sNat(N)) => get(L, N)

  declare getl : K -> List
  define getl(list(L)) => L

  declare getattr : Expression #String -> K
  define getattr(obj(_,<oattrs> Attrs:Map </oattrs>), S:#String) => Attrs(S)
  context getattr(HOLE,_)

  declare getref : Expression #String -> K
  define getref(obj(_,<oattrs> Attrs </oattrs>), S) => ref(Attrs(S))
  context getref(HOLE,_)

  syntax ListItem ::= "(" K "," Bag "," List "," List "," List "," K ")"

  rule binaryOp(O, O2:Object, S, S2, K:K) => test(and(istype(O, ref(S)), istype(O2, ref(S2))), K, ref("NotImplemented"))
  rule unaryOp(O, S, K) => test(istype(O, ref(S)), K, ref("NotImplemented"))

  macro gettype(E:Expression) = getref(E, "__class__")
  macro getbases(E) = getattr(E, "__bases__")

  //TODO: subclasshook
  rule istype(O:Object, Type:Object) => hasbase(gettype(O), Type)

  //needs predicates to work without obj()
  rule hasbase(obj(N:#Nat,ObjState:Bag), Base:Object) => or(obj(N,ObjState) ==Bool Base, hasbase(getbases(obj(N,ObjState)), Base))

  rule hasbase(list(ListItem(N) L), Base) => or(hasbase(ref(N), Base),hasbase(list(L), Base))
  rule hasbase(list(.List), Base) => false

  rule <k> invokeBuiltin(obj("get_attr",_), ListItem(obj(_, <oattrs>... "__name__" |-> S ...</oattrs>)) ListItem(O) ListItem(_), .) => getattr(O, S) ...</k>
  rule <k> invokeBuiltin(obj("get_ref",_), ListItem(obj(_, <oattrs>... "__name__" |-> S ...</oattrs>)) ListItem(O) ListItem(_), .) => getref(O, S) ...</k>

  rule <k> ref(S) => ref(N) ...</k>
       <symbols>... S |-> N ...</symbols>

  rule <k> ref(S) => obj(S2:#String,<oattrs>Attrs</oattrs>) ...</k>
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

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> N "__method__" |-> T:#Bool ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when (T andBool lengthList L =/=Bool sNat(N)) orBool ((notBool T) andBool lengthList L =/=Bool N)

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at least " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when N =/=Bool I andBool ((T andBool lengthList L <Int sNat(N)) orBool ((notBool T) andBool lengthList L <Int N))

  rule <k> invokeBuiltin(obj(S,<oattrs>... "__min__" |-> N "__max__" |-> I "__method__" |-> T ...</oattrs>), L, .) => raiseInternal("TypeError", S +String " expected at most " +String Int2String(N) +String " arguments, got " +String Int2String(lengthList L -Int 1)) ...</k> when I >=Int 0 andBool N =/=Bool I andBool ((T andBool lengthList L >Int I +Int 1) orBool ((notBool T) andBool lengthList L >Int I))

  context list(.) ~> iterate(HOLE,_)

  rule <k> iterate(O, K) => try: (list(.) ~> iterate(ref("iter") (O), K)) except ref("TypeError") : test(K ==Bool ., raise, K) else: pass ...</k>
  rule <k> list(L) ~> iterate(O, K) => try: addItem(getmember(O,  #id "__next__", true, false, false) ()) except ref("StopIteration") : list(L) else: (list(L) ~> iterate(O, K)) ...</k>
  rule <k> (addItem(O) => .) ~> popx ~> list(_ (. => ListItem(O))) ...</k>
  rule <k> list(L) ~> setx(K) => setx(K) ~> list(L) ...</k>
  rule <k> list(L) ~> popx => popx ~> list(L) ...</k>

  rule <k> mapping(O, K) => iterate(getmember(O, #id "keys", true, false, false) () -> K, raiseInternal("TypeError", "o.keys() are not iterable")) ~> map(.) ~> mapping(O, K) ...</k>
  rule <k> list((ListItem(B:Builtin) => .) _) ~> (. => addPair(B, (O [ ref(B) ]))) ~> map(_) ~> mapping(O,_) ...</k>
  rule <k> list(_) ~> (addPair(B, O) => .) ~> map(_ (. => B |-> O)) ...</k>
  rule <k> (list(.) => .) ~> map(_) ~> (mapping(_,_) => .) ...</k>

  rule <k> newHelper(O, Type, St:Set) => test(hasbase(O, Type), test(id(O) in lookup(Sym, St), raiseInternal("TypeError", "unsafe builtin __new__ call error message"), .), raiseInternal("TypeError", "invalid builtin __new__ call argument type error message")) ...</k>
       <symbols> Sym:Map </symbols>

  rule <k> raiseInternal(S, S2) => raise mutable("args" |-> undefined(S2),ref(S)) ...</k>

end module
