require "python-semantics-common.k"

module PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "builtins"
             | "resolve"
             | "modules"
             | "importlib"
             | "object" K "(" K "," List "," Map "," Map ")"
             | "def" String "(" Int "," Int "," Bool ")"
             | "incref" "(" List "," Int ")"
             | "incref" "(" ObjId "," Int ")"
             | "genv" "(" String "," String ")"
             | "module" K "(" Expression ")" [strict(2)]

  syntax ListItem ::= "refs" "(" List ")"

  rule incref(B:ObjId,N) => incref(ListItem(B),N) [macro, anywhere]
  rule refs(ListItem(S) L) => ListItem(ref(S)) refs(L)
  rule refs(.List) => .List

  rule <k> initialize(Program:K) => builtins ~> resolve ~> modules ~> importlib ~> executeModule(codeObject(String2Id("__main__"), .Parameters, Program, true), ref("builtins"), {.KeyData}) ...</k>

  rule <k> (. => setref(B, "__dict__", { DeMapify(Env:Map) })) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oenv> Env </oenv>
       ...</object>
       <references>... B |-> (1 => 0) ...</references>
       <bootstrapping> 1 </bootstrapping>

  rule <k> (. => setref(B, "__bases__", immutable(list(L), ref("tuple")))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__bases__" |-> list(L:List) ...</oattrs>
       ...</object>
       <references>... B |-> (3 => 2) ...</references> 
       <bootstrapping> 3 </bootstrapping>

  rule <k> (. => setref(B, "__mro__", immutable(getMro(ref(B), getref2(ref(B), "__bases__")), ref("tuple")))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__mro__" |-> _ ...</oattrs>
       ...</object>
       <references>... B |-> (2 => 1) </references>
       <bootstrapping> 2 </bootstrapping>        

  rule <references>... (_ |-> 0) => . ...</references>

  rule <k> resolve => . ...</k>
       <references> .Map </references>

  rule <k> resolve ...</k>
       <references> M:Map </references>
       <bootstrapping> N => N -Int 1 </bootstrapping> when notBool (N in values M)

  rule <k> (. => incref(N, #if S2 ==String "type" #then 3 #else 0 #fi)) ~> object (S:String => N:Int)(S2:String,_,_,_) ...</k>
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

  rule <k> (def S:String(Min:Int, Max:Int, IsMethod:Bool) => ref(S)) ...</k>
       (. => <object>...
         <id>S</id>
         <oattrs> "__min__" |-> Min "__max__" |-> Max "__method__" |-> IsMethod "__class__" |-> #if IsMethod #then ref("builtin-method") #else ref("builtin-function") #fi </oattrs>
         <oenv> .Map </oenv>
       ...</object>)
       <symbols> M:Map => M[S / S] </symbols> when notBool(S in keys(M))

  rule <k> object N(_,_,_,(S |-> def S2:String(Min, Max, IsMethod) => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs:Map => OAttrs[ref(S2) / S] </oattrs>
       ...</object>
       (. => <object>...
         <id>S2</id>
         <oattrs> "__min__" |-> Min "__max__" |-> Max "__method__" |-> IsMethod "__class__" |-> #if IsMethod #then ref("builtin-method") #else ref("builtin-function") #fi </oattrs>
         <oenv> .Map </oenv>
       ...</object>)
       <symbols> M => M[S2 / S2] </symbols> when notBool(S2 in keys(M))

  rule <k> object N(_,_,_,(S |-> K:K => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[K / S] </oattrs>
       ...</object> when getKLabel K =/=KLabel 'ref`(_`) andBool getKLabel K =/=KLabel 'def_`(_`,_`,_`)

  rule <k> object N(_,_,_,(S |-> ref(S2) => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[ref(S2) / S] </oattrs>
       ...</object>

  rule <k> object N(.,.,.,.) => . ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs </oattrs>
       ...</object> when "__bases__" in keys(OAttrs) orBool OAttrs:Map("__class__") =/=K ref("type")

  rule <k> incref((ListItem(B) => .) _, N2:Int) ...</k>
       <references>... B |-> (N => N +Int N2) ...</references>
  rule <k> incref((ListItem(B) => .) _, N2) ...</k>
       <references>Ref:Map (. => (B |-> N2)) </references> when notBool(B in keys(Ref))
  rule incref(.List,_) => .

  rule <k> module S(O) => ((ref(N) . String2Id("__dict__") ["__name__"]), .Expressions) := S ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> ref(id(O)) "__class__" |-> ref("module") </oattrs>
       ...</object>)
       <symbols>... (. => S |-> N) ...</symbols>
       <builtinModules>... (. => S |-> N) ...</builtinModules> [allocation]

endmodule
