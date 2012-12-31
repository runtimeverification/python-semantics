require "python-semantics-common.k"
require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-LITERALS
  imports PYTHON-SEMANTICS-COMMON
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax ObjRef ::= "hash" "(" Expression ")" [strict]

  syntax K ::= "processDict" "(" Expression "," Map ")" [strict(1)]
             | "processDictElement" "(" Expression "," Expression "," Expression "," Expression ")" [strict]
             | "processSet" "(" Expression "," List ")" [strict(1)]
             | "processSetElement" "(" Expression "," Expression "," Expression ")" [strict]
             | "tableInsert" "(" Builtin "," Int "," Expression "," K ")" [strict(3)]
             | "tableLookup" "(" Builtin "," Int "," Expression ")" [strict(3)]
             | "tableDelete" "(" Builtin "," Int "," Expression ")" [strict(3)]
             | "bucketInsert" "(" Builtin "," Int "," Expression "," Expression "," List "," List ")" [strict(3, 4)]
             | "bucketLookup" "(" Expression "," List ")" [strict(1)]
             | "bucketDelete" "(" Builtin "," Int "," Expression "," List "," List ")" [strict(3)]
             | "setBucket" "(" Builtin "," Int "," List ")"
 
  syntax Builtin ::= "key" "(" KeyDatum ")" [function]
  rule key(B : _) => B [function, anywhere]

  syntax Builtin ::= "value" "(" KeyDatum ")" [function]
  rule value(_ : B) => B [function, anywhere]

  rule <k> I:Int => immutable(I,ref("int")) ...</k>
  rule <k> S:String => immutable(S,ref("str")) ...</k>
  rule <k> b S:String => immutable(S, ref("bytes")) ...</k>
  rule <k> F:Float => immutable(F,ref("float")) ...</k>
  rule <k> tuple(Osc:Expressions) => immutable(list(Refify(Idify(Listify(Osc)))), ref("tuple")) ...</k> when isKResult(Osc)
  rule <k> [ Osc:Expressions ] => mutable(list(Refify(Idify(Listify(Osc)))), ref("list")) ...</k> when isKResult(Osc)
  rule <k> { Osc:Expressions } => processSet(mutable(map(.),ref("set")), Listify(Osc)) ...</k> when isKResult(Osc)
  rule <k> { OPs:KeyData } => processDict(mutable(map(.),ref("dict")), Mapify(OPs)) ...</k> when isKResult(OPs)

  rule <k> (. => processDictElement(Dict:Object, Key:Object, (ref("hash")(Key, .Arguments)), Value:K)) ~> processDict(Dict, _ (Key |-> Value => .)) ...</k>

  rule <k> processDict(Dict:Object, .) => ref(id(Dict)) ...</k>

  rule <k> (. => processSetElement(SetObj:Object, Element:Object, (ref("hash")(Element, .Arguments)))) ~> processSet(SetObj, (ListItem(Element) => .) _) ...</k>
  context processSet(_, ListItem(HOLE) _) when getKLabel HOLE ==KLabel 'ref`(_`)

  rule <k> processSet(SetObj:Object, .) => ref(id(SetObj)) ...</k>

  syntax K ::= "checkHash" "(" Expression ")" [strict]

  rule <k> invokeBuiltin(obj("hash",_), ListItem(O:Object), .) => checkHash(getmember(O, "__hash__", true, false, false) (.Arguments) -> (raiseInternal("TypeError", "unhashable type"))) ...</k>

  rule <k> checkHash(O:Object) => test(istype(O, ref("int")), O, raiseInternal("TypeError", "__hash__ method should return an integer")) ...</k>

  rule <k> processDictElement(obj(B:Builtin,_), Key:Object, Hash:Object, Value:K) => tableInsert(B, intvalue(Hash), Key, ref(id(Key)) : ref(id(Value))) ...</k>

  rule <k> processSetElement(obj(B,_), Element:Object, Hash:Object) => tableInsert(B, intvalue(Hash), Element, ref(id(Element))) ...</k>

  rule <k> tableInsert(B, H:Int, Key, K:K) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M:Map => M[list(ListItem(K))/H]) ...</oattrs>
       ...</object> when notBool (H in keys(M))

  rule <k> tableInsert(B, H, Key, K) => bucketInsert(B, H, Key, K, Values:List, .) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(_ H |-> list(Values)) ...</oattrs>
       ...</object>

  rule bucketInsert(B, H, Key, K, ListItem(Key2 : Value2) Suffix:List, Prefix:List) => test(plbool(Key == Key2), setBucket(B, H, Prefix ListItem(K) Suffix), bucketInsert(B, H, Key, K, Suffix, Prefix ListItem(Key2 : Value2)))

  rule <k> bucketInsert(B, H, Key, K, ., Prefix) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M => M[list(Prefix ListItem(K))/H]) ...</oattrs>
       ...</object>

  rule <k> setBucket(B, H, Values) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M => M[list(Values)/H]) ...</oattrs>
       ...</object> when Values =/=List .

  rule <k> setBucket(B, H, .) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M => M[undef/H]) ...</oattrs>
       ...</object>

  rule <k> tableLookup(B, H, Key) => bucketLookup(Key, Values) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(_ H |-> list(Values)) ...</oattrs>
       ...</object>

  rule <k> tableLookup(B, H:Int, Key) => raise ref("KeyError") (Key, .Arguments) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M) ...</oattrs>
       ...</object> when notBool(H in keys(M))

  rule bucketLookup(Key, ListItem(Key2 : Value2) Suffix) => test(plbool(Key == Key2), Value2, bucketLookup(Key, Suffix))
  rule bucketLookup(Key, .) => raise ref("KeyError") (Key, .Arguments)

  rule <k> tableDelete(B, H, Key) => bucketDelete(B, H, Key, Values, .) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(_ H |-> list(Values)) ...</oattrs>
       ...</object>

  rule <k> tableDelete(B, H:Int, Key) => raise ref("KeyError") (Key, .Arguments) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> map(M) ...</oattrs>
       ...</object> when notBool(H in keys(M))

  rule bucketDelete(B, H, Key, ListItem(Key2 : Value2) Suffix, Prefix) => test(plbool(Key == Key2), setBucket(B, H, Prefix Suffix), bucketDelete(B, H, Key, Suffix, Prefix ListItem(Key2 : Value2)))
  rule bucketDelete(_, _, Key, ., _) => raise ref("KeyError") (Key, .Arguments)

  rule <k> mutable(V:Value,O) => mutable("__value__" |-> V "__revision__" |-> 0, O) ...</k>
  rule <k> mutable(M,obj(B,ObjState)) => mutable(M,N,obj(B,ObjState)) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc> [allocation]

  rule <k> mutable(M:Map,N,obj(B,_)) => ref(N) ...</k>
       (. =>
       <object>...
         <id>N</id>
         <oattrs> "__class__" |-> ref(B) M </oattrs>
       ...</object>)

  rule immutable(V:Value, O) => immutable("__value__" |-> V, O)

  syntax K ::= pair(Map, Builtin)
  syntax ObjRef ::= mutable(Map, Int, Expression) [strict(3)]

  rule <k> immutable(M, obj(B,_)) => O ...</k>
       <literals>... pair(M, B) |-> O ...</literals>

  rule <k> immutable(M, obj(B,ObjState)) => mutable(M, N, obj(B,ObjState)) ...</k>
       <literals> Literals:Map (. => pair(M, B) |-> ref(N)) </literals>
       <nextLoc> N => N +Int 1 </nextLoc> when notBool(pair(M, B) in keys(Literals)) [allocation]

endmodule
