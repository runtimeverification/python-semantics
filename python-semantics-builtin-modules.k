require "python-semantics-functions.k"


module PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-FUNCTIONS

  syntax K ::= "builtins"
             | "resolve"
             | "modules"
             | "importlib"
             | "object" ObjId "(" String "," List "," Map "," Map ")"
             | "incref" "(" ObjId "," Set ")"
             | "genv" "(" String "," String ")"
             | "module" ObjId "(" Expression ")" [strict(2)]
             | "struct" ObjId "(" Expressions ")"
             | invokeBuiltin(String)

  syntax ObjRef ::= "def" String "(" Bool "," Parameters")"

  syntax ListItem ::= "refs" "(" List ")"

  rule refs(ListItem(S) L) => ListItem(ref(S)) refs(L)
  rule refs(.List) => .List

  rule <k> incref(B:ObjId, (SetItem(N) => .) _) ...</k>
       <references>... . => (B, N) ...</references>

  syntax SetItem ::= (ObjId, Int)

  rule incref(B, .) => .

  rule <k> initialize(Program:K) => builtins ~> resolve ~> modules ~> importlib ~> executeModule(codeObject(String2Id("__main__"), .Parameters, Program, true), ref("builtins"), {.KeyData}) ...</k>

  rule <k> (. => setref(N, "__dict__", { DeMapify(Env:Map) })) ~> resolve ...</k>
       <object>...
         <id>N:Int</id>
         <oenv> Env </oenv>
       ...</object>
       <references>... (N, 1) => . ...</references>
       <bootstrapping> 1 </bootstrapping>

  rule <k> (. => setref(B, "__bases__", immutable(list(L), ref("tuple")))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__bases__" |-> list(L:List) ...</oattrs>
       ...</object>
       <references>... (B, 4) => . ...</references> 
       <bootstrapping> 4 </bootstrapping>

  rule <k> (. => setref(B, "__mro__", immutable(getMro(ref(B), getref2(ref(B), "__bases__")), ref("tuple")))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__mro__" |-> _ ...</oattrs>
       ...</object>
       <references>... (B, 3) => . ...</references>
       <bootstrapping> 3 </bootstrapping>        

  rule <k> . => setref(S, "__code__", codeObject(String2Id(S), Ps, invokeBuiltin(S), false)) ~> setref(S, "__closure__", ref("None")) ~> setattr(S, "__globals__", .Obj) ~> setref(S, "__defaults__", ref("None")) ~> setref(S, "__kwdefaults__", ref("None")) ~> makeBuiltinDefaults(S, Listify(Ps), false, ., .) ...</k>
       <object>...
         <id>S:String</id>
         <oattrs>... "__code__" |-> Ps ...</oattrs>
       ...</object>
       <references>... (S, 2) => . ...</references>
       <bootstrapping> 2 </bootstrapping>

  rule <k> invokeBuiltin(S) => invokeBuiltin(S, M) ...</k>
       <frameObject> ref(N) </frameObject>
       <object>...
         <id>N</id>
         <oattrs>... "f_locals" |-> map(M) ...</oattrs>
       ...</object>

  context invokeBuiltin(_, _ (_ |-> HOLE))

  syntax K ::= makeBuiltinDefaults(String, List, Bool, List, Map)
  rule makeBuiltinDefaults(S, (ListItem(X = K:K) => .) _, false, _ (. => ListItem(K)), _)
  rule makeBuiltinDefaults(S, (ListItem(X = K:K) => .) _, true, _, _ (. => Id2String(X) |-> K))
  rule makeBuiltinDefaults(S, (ListItem(X) => .) _, _, _, _)
  rule makeBuiltinDefaults(S, (ListItem(* _) => ListItem(*)) _, _, _, _)
  rule makeBuiltinDefaults(S, (ListItem(*) => .) _, false => true, _, _)
  rule makeBuiltinDefaults(S, (ListItem(** _) => .) _, _, _, _)
  rule makeBuiltinDefaults(S, ., _, Defaults, KwDefaults) => setref(S, "__defaults__", immutable(list(Defaults), ref("tuple"))) ~> setref(S, "__kwdefaults__", { DeMapify(KwDefaults) })

  rule <k> resolve => . ...</k>
       <references> .Set </references>

  rule <k> resolve ...</k>
       <references> S:Set </references>
       <bootstrapping> N => N -Int 1 </bootstrapping> when notBool (N in values S)

  syntax Set ::= "values" Set [function]
  rule values ((_, N:Int) S:Set) => SetItem(N) values S
  rule values .Set => .Set

  syntax Set ::= "#if" Bool "#then" Set "#else" Set "#fi" [function]

  rule <k> (. => #if S2 ==String "type" #then incref(N, SetItem(4) SetItem(3) SetItem(1)) #else . #fi) ~> object (S:String => N:Int)(S2:String,_,_,_) ...</k>
       <nextLoc>N => N +Int 1</nextLoc>
       <store>... . =>
         <object>...
           <id>N</id>
           <oattrs> "__name__" |-> S </oattrs>
           <oenv> .Map </oenv>
         ...</object>
       </store>
       <symbols>(. => S |-> N) M</symbols> when notBool(S in keys(M)) [allocation]

  rule <k> object N:Int((S:String => .),_,_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__class__" |-> ref(S) ...</oattrs>
       ...</object>

  rule <k> object N(.,.,_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>(. => "__bases__" |-> list(.List) "__mro__" |-> .) M</oattrs>
       ...</object> when notBool("__bases__" in keys(M)) andBool M:Map("__class__") ==K ref("type")

  rule <k> object N(_,(L => .List),_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__bases__" |-> list(refs(L)) "__mro__" |-> . ...</oattrs>
       ...</object> when L =/=List .List

  rule <k> object N(_,_,(S |-> ref(S2) => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> ref(S2) ...</oenv>
       ...</object>

  context object N(_, _, S |-> HOLE _, _) when getKLabel HOLE =/=KLabel 'ref`(_`)

  rule <k> object N(_,_,(S |-> O:Object => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> ref(id(O)) ...</oenv>
       ...</object>

  rule <k> def S:String(IsMethod, Ps) => incref(S, SetItem(2)) ~> ref(S) ...</k>
       (. => <object>...
         <id>S</id>
         <oattrs> "__class__" |-> #if IsMethod #then ref("builtin-method") #else ref("builtin-function") #fi "__code__" |-> Ps </oattrs>
         <oenv> .Map </oenv>
       ...</object>)
       <symbols> M:Map => M[S / S] </symbols> when notBool(S in keys(M))

  rule <k> object N(_,_,_,(S |-> K:K => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[K / S] </oattrs>
       ...</object> when isObject(K) =/=K true

  rule <k> object N(_,_,_,(S |-> K:K => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[ref(id(K)) / S] </oattrs>
       ...</object> when isObject(K)


  context object N(_,_,_,(S |-> HOLE) _) when getKLabel HOLE ==KLabel 'def_`(_`,_`)

  rule <k> object N(.,.,.,.) => . ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs </oattrs>
       ...</object> when "__bases__" in keys(OAttrs) orBool OAttrs:Map("__class__") =/=K ref("type")

  rule <k> module S(O) => ((ref(N) . String2Id("__dict__") ["__name__"]), .Expressions) := S ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> ref(id(O)) "__class__" |-> ref("module") </oattrs>
       ...</object>)
       <symbols>... (. => S |-> N) ...</symbols>
       <builtinModules>... (. => S |-> N) ...</builtinModules> [allocation]

  rule <k> (. => incref(N, SetItem(4) SetItem(3) SetItem(1))) ~> struct (S:String => N)(K) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__class__" |-> ref("type") "__bases__" |-> list(ListItem(ref("tuple"))) "__order__" |-> list(.List) "__name__" |-> S "__mro__" |-> . </oattrs>
         <oenv> "__new__" |-> ref("structseq.__new__") </oenv>
       ...</object>)
       <symbols>... (. => S |-> N) ...</symbols> [allocation]

  rule <k> (. => object S +String "_structseq"("attribute", ., ., "__get__" |-> "__value__"[lengthList L])) ~> struct N:Int((S:String , K) => K) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "__order__" |-> list(L (. => ListItem(S))) ...</oattrs>
         <oenv>... . => S |-> ref(S +String "_structseq") ...</oenv>
       ...</object>

  rule struct _(.Expressions) => .

endmodule
