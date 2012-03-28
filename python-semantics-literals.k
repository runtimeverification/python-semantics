module PYTHON-SEMANTICS-LITERALS
  imports PYTHON-SEMANTICS-COMMON
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax ObjRef ::= "hash" "(" Expression ")" [:strict:]

  syntax K ::= "processDict" "(" Expression "," Map ")" [:strict(1):]
             | "processDictElement" "(" Expression "," Expression "," Expression "," Expression ")" [:strict:]
             | "processSet" "(" Expression "," List ")" [:strict(1):]
             | "processSetElement" "(" Expression "," Expression "," Expression ")" [:strict:]
             | "tableInsert" "(" Builtin "," #Int "," Expression "," K ")" [:strict(3):]
             | "tableLookup" "(" Builtin "," #Int "," Expression ")" [:strict(3):]
             | "bucketInsert" "(" Builtin "," #Int "," Expression "," Expression "," List "," List ")" [:strict(3 4):]
             | "bucketLookup" "(" Expression "," List ")" [:strict(1):]
             | "setBucket" "(" Builtin "," #Int "," List ")"
 
  declare key : KeyDatum -> Builtin
  define key(B : _) => B

  declare value : KeyDatum -> Builtin
  define value(_ : B) => B

  rule <k> I:#Int => immutable(I,ref("int")) ...</k>
  rule <k> S:#String => immutable(S,ref("str")) ...</k>
  rule <k> F:#Float => immutable(F,ref("float")) ...</k>
  rule <k> tuple(Osc:Expressions) => immutable(list(Idify(Listify(Osc))), ref("tuple")) ...</k>
  rule <k> [ Osc ] => mutable(list(Idify(Listify(Osc))), ref("list")) ...</k>
  rule <k> { Osc } => processSet(mutable(map(.),ref("set")), Listify(Osc)) ...</k>
  rule <k> { OPs:KeyData } => processDict(mutable(map(.),ref("dict")), Mapify(OPs)) ...</k>

  rule <k> (. => processDictElement(Dict:Object, Key:Object, (ref("hash")(Key)), Value:K)) ~> processDict(Dict, _ (Key |-> Value => .)) ...</k>

  rule <k> processDict(Dict, .) => ref(id(Dict)) ...</k>

  rule <k> (. => processSetElement(Set:Object, Element:Object, (ref("hash")(Element)))) ~> processSet(Set, (ListItem(Element) => .) _) ...</k>

  rule <k> processSet(Set, .) => ref(id(Set)) ...</k>

  syntax K ::= "checkHash" "(" Expression ")" [:strict:]

  rule <k> invokeBuiltin(obj("call_hash",_), ListItem(O:Object), .) => checkHash(getmember(O, #id "__hash__", true, false, false) () -> (raiseInternal("TypeError", "unhashable type"))) ...</k>

  rule <k> checkHash(O) => test(istype(O, ref("int")), O, raiseInternal("TypeError", "__hash__ method should return an integer")) ...</k>

  rule <k> processDictElement(obj(B:Builtin,_), Key, Hash:Object, Value) => tableInsert(B, intvalue(Hash), Key, id(Key) : id(Value)) ...</k>

  rule <k> processSetElement(obj(B,_), Element, Hash) => tableInsert(B, intvalue(Hash), Element, id(Element)) ...</k>

  rule <k> tableInsert(B, H:#Int, Key, K:K) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M:Map => M[list(ListItem(K))/H]) ...</oattrs>
       ...</object> when notBool (H in keys(M))

  rule <k> tableInsert(B, H, Key, K) => bucketInsert(B, H, Key, K, Values:List, .) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(_ H |-> list(Values)) ...</oattrs>
       ...</object>

  rule <k> bucketInsert(B, H, Key, K, ListItem(Key2:Builtin : Value2:Builtin) Suffix:List, Prefix:List) => test(plbool(Key == ref(Key2)), setBucket(B, H, Prefix ListItem(K) Suffix), bucketInsert(B, H, Key, K, Suffix, Prefix ListItem(Key2 : Value2))) ...</k>

  rule <k> bucketInsert(B, H, Key, K, ., Prefix) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M => M[list(Prefix ListItem(K))/H]) ...</oattrs>
       ...</object>

  rule <k> setBucket(B, H, Values) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M => M[list(Values)/H]) ...</oattrs>
       ...</object>

  rule <k> tableLookup(B, H, Key) => bucketLookup(Key, Values) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(_ H |-> list(Values)) ...</oattrs>
       ...</object>

  rule <k> tableLookup(B, H, Key) => raise ref("KeyError") (Key) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M) ...</oattrs>
       ...</object> when notBool(H in keys(M))

  rule <k> bucketLookup(Key, ListItem(Key2 : Value2) Suffix) => test(plbool(Key == ref(Key2)), ref(Value2), bucketLookup(Key, Suffix)) ...</k>
  rule <k> bucketLookup(Key, .) => raise ref("KeyError") (Key) ...</k>

  syntax K ::= "pair" "(" Value "," Builtin ")"
 
  rule <k> copy(obj(B,_), O) => immutable(V, O) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> V ...</oattrs>
       ...</object>

  rule <k> immutable(V:Value,obj(B:Builtin,_)) => ref(N:#Nat) ...</k>
       <literals>... pair(V,B) |-> N ...</literals>

  rule <k> immutable(V,obj(B,_)) => ref(N) ...</k>
       <literals> Ref:Map (. => pair(V,B) |-> N) </literals>
       <nextLoc> N => sNat(N) </nextLoc>
       (. =>
       <object>...
         <id>N</id>
         <oattrs> "__class__" |-> B "__value__" |-> V </oattrs>
       ...</object>) when notBool((V,B) in keys(Ref))

  rule <k> mutable(V,O) => mutable("__value__" |-> V "__revision__" |-> 0, O) ...</k>

  rule <k> mutable(M:Map,obj(B,_)) => ref(N) ...</k>
       <nextLoc> N => sNat(N) </nextLoc>
       (. =>
       <object>...
         <id>N</id>
         <oattrs> "__class__" |-> B M </oattrs>
       ...</object>)

end module
