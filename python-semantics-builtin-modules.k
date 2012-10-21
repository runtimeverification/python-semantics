require "python-semantics-common.k"

module PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "builtins"
             | "resolve"
             | "modules"
             | "object" K "(" K "," List "," Map "," Map ")"
             | "def" String "(" Int "," Int "," Bool ")"
             | "incref" "(" List "," Int ")"
             | "incref" "(" String "," Int ")"
             | "genv" "(" String "," String ")"
             | "module" K "(" Expression ")" [strict(2)]

  syntax ListItem ::= "refs" "(" List ")"

  rule incref(S:String,N) => incref(ListItem(S),N) [macro, anywhere]
  rule refs(ListItem(S) L) => ListItem(ref(S)) refs(L)
  rule refs(.List) => .List

  rule <k> initialize(Program:K) => builtins ~> resolve ~> modules ~> executeModule(codeObject(String2Id("__main__"), .Parameters, Program, true), ref("builtins"), {.KeyData}) ...</k>

  rule <k> resolve ...</k>
       <oenv>... (_ |-> (ref(S) => B)) ...</oenv>
       <symbols>... S |-> B:Builtin ...</symbols>
       <references>... S |-> (N => N -Int 1) ...</references>

  rule <k> (. => setenv(B, S, ref(B2))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oenv>... S:String |-> B2:Builtin => . ...</oenv>
       ...</object>
       <references>... S |-> (N => N -Int 1) ...</references>

  rule <k> resolve ...</k>
       <oattrs>... _ |-> list(_ (ListItem(ref(S)) => ListItem(B)) _) ...</oattrs>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (N => N -Int 1) ...</references>

  rule <k> (. => setref(B, "__bases__", immutable(list(L), ref("tuple")))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__bases__" |-> list(L:List) ...</oattrs>
       ...</object>
       <symbols>... S:String |-> B:Builtin ...</symbols>
       <references>... S |-> (N => N -Int 1) ...</references> when all(L, isBuiltin)

  rule <k> (. => setref(B, "__mro__", immutable(getMro(B, getref2(ref(B), "__bases__")), ref("tuple")))) ~> resolve ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__mro__" |-> _ ...</oattrs>
       ...</object>
       <symbols>... S:String |-> B:Builtin ...</symbols>
       <references>M:Map S |-> (1 => 0) </references> when values M ==Set SetItem(1) orBool M ==Map .

  rule <k> resolve ...</k>
       <oattrs>... _ |-> (ref(S) => B) ...</oattrs>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (N => N -Int 1) ...</references>

  rule <k> resolve ...</k>
       <xcontext>... (ref(S) => B) ...</xcontext>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (N => N -Int 1) ...</references>
 
  rule <references>... (_ |-> 0) => . ...</references>

  rule <k> resolve => . ...</k>
       <references> .Map </references>

  rule <k> (. => incref(S, #if S2 ==String "type" #then 2 #else 0 #fi)) ~> object (S:String => N:Int)(S2:String,_,_,_) ...</k>
       <nextLoc>N => N +Int 1</nextLoc>
       <store>... . =>
         <object>...
           <id>N</id>
           <oattrs> "__name__" |-> S </oattrs>
         ...</object>
       </store>
       <symbols>(. => S |-> N) M</symbols> when notBool(S in keys(M))

  rule <k> (. => incref(S:String,1)) ~> object N((S => .),_,_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__class__" |-> ref(S) ...</oattrs>
       ...</object>

  rule <k> object N(.,.,_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>(. => "__bases__" |-> list(.List) "__mro__" |-> .) M</oattrs>
       ...</object> when notBool("__bases__" in keys(M)) andBool M("__class__") ==K ref("type")

  rule <k> (. => incref(L:List,1)) ~> object N(_,(L => .List),_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__bases__" |-> list(refs(L)) "__mro__" |-> . ...</oattrs>
       ...</object> when L =/=List .List

  rule <k> (. => incref(S2:String,1) ~> incref(S:String, 1)) ~> object N(_,_,(S |-> ref(S2) => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> ref(S2) ...</oenv>
       ...</object>

  context object N(_, _, S |-> HOLE _, _) when getKLabel HOLE =/=KLabel 'ref`(_`)

  rule <k> (. => incref(S:String, 1)) ~> object N(_,_,(S |-> O:Object => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> id(O) ...</oenv>
       ...</object>

  rule <k> (. => #if IsMethod #then incref("builtin-method",1) #else incref("builtin-function",1) #fi) ~> (def S:String(Min:Int, Max:Int, IsMethod:Bool) => ref(S)) ...</k>
       (. => <object>...
         <id>S</id>
         <oattrs> "__min__" |-> Min "__max__" |-> Max "__method__" |-> IsMethod "__class__" |-> #if IsMethod #then ref("builtin-method") #else ref("builtin-function") #fi </oattrs>
       ...</object>)
       <symbols> M:Map => M[S / S] </symbols> when notBool(S in keys(M))

  rule <k> (. => #if IsMethod #then incref("builtin-method",1) #else incref("builtin-function",1) #fi) ~> object N(_,_,_,(S |-> def S2:String(Min, Max, IsMethod) => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs:Map => OAttrs[S2 / S] </oattrs>
       ...</object>
       (. => <object>...
         <id>S2</id>
         <oattrs> "__min__" |-> Min "__max__" |-> Max "__method__" |-> IsMethod "__class__" |-> #if IsMethod #then ref("builtin-method") #else ref("builtin-function") #fi </oattrs>
       ...</object>)
       <symbols> M => M[S2 / S2] </symbols> when notBool(S2 in keys(M))

  rule <k> object N(_,_,_,(S |-> K:K => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[K / S] </oattrs>
       ...</object> when getKLabel K =/=KLabel 'ref`(_`) andBool getKLabel K =/=KLabel 'def_`(_`,_`,_`)

  rule <k> (. => incref(S2:String, 1)) ~> object N(_,_,_,(S |-> ref(S2) => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[ref(S2) / S] </oattrs>
       ...</object>

  rule <k> object N(.,.,.,.) => . ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs </oattrs>
       ...</object> when "__bases__" in keys(OAttrs) orBool OAttrs("__class__") =/=K ref("type")

  rule <k> incref((ListItem(S) => .) _, N2:Int) ...</k>
       <references>... S |-> (N => N +Int N2) ...</references>
  rule <k> incref((ListItem(S:String) => .) _, N2) ...</k>
       <references>Ref:Map (. => (S |-> N2)) </references> when notBool(S in keys(Ref))
  rule incref(.List,_) => .

  rule <k> module S(O) => ((ref(N) . String2Id("__dict__") ["__name__"]), .Expressions) := S ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> id(O) "__class__" |-> Module </oattrs>
       ...</object>)
       <symbols>... (. => S |-> N) "module" |-> Module:Int ...</symbols>

endmodule
