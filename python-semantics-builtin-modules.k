module PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "builtins"
             | "resolve"
             | "object" K "(" K "," List "," Map "," Map ")"
             | "def" #String "(" #Int "," #Int "," #Bool ")"
             | "incref" "(" List "," #Nat ")"
             | "incref" "(" #String "," #Nat ")"
             | "genv" "(" #String "," #String ")"

  syntax ListItem ::= "refs" "(" List ")"
                    | "root"

  macro incref(S,N) = incref(ListItem(S),N)
  rule refs(ListItem(S) L) => ListItem(ref(S)) refs(L)
  rule refs(.List) => .List

  rule <k> initialize => (builtins ~> resolve) ...</k>

  rule <k> resolve ...</k>
       <oenv>... (_ |-> (ref(S) => B)) ...</oenv>
       <symbols>... S |-> B:Builtin ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>

  rule <k> resolve ...</k>
       <oattrs>... _ |-> list(_ (ListItem(ref(S)) => ListItem(B)) _) ...</oattrs>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>

  rule <k> resolve ...</k>
       <oattrs>... _ |-> (ref(S) => B) ...</oattrs>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>

  rule <k> resolve ...</k>
       <env>... _ |-> (ref(S) => B) ...</env>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>

  rule <k> resolve ...</k>
       <xcontext>... (ref(S) => B) ...</xcontext>
       <symbols>... S |-> B ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>
 
  rule <k> resolve ...</k>
       <symbols>... _ |-> obj(_, <oattrs>... _ |-> (ref(S) => B) ...</oattrs>) S |-> B ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>

  rule <k> resolve ...</k>
       <symbols>... _ |-> obj(_, <oattrs>... _ |-> list(_ (ListItem(ref(S)) => ListItem(B)) _) ...</oattrs>) S |-> B ...</symbols>
       <references>... S |-> (sNat(N) => N) ...</references>

  rule <references>... (_ |-> 0) => . ...</references>

  rule <k> resolve => . ...</k>
       <references> .Map </references>

  rule <k> object (S:#String => N:#Nat)(_,_,_,_) ...</k>
       <nextLoc>N => N +Int 1</nextLoc>
       <store>... . =>
         <object>...
           <id>N</id>
           <oattrs> "__name__" |-> S </oattrs>
         ...</object>
       </store>
       <symbols>... . => S |-> N ...</symbols>

  rule <k> (. => incref(S,1)) ~> object N((S => .),_,_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__class__" |-> ref(S) ...</oattrs>
       ...</object>

  rule <k> object N(_,(root => .),_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__bases__" |-> list(.List) ...</oattrs>
       ...</object>

  rule <k> (. => incref(L:List,1)) ~> object N(_,(L => .List),_,_) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... . => "__bases__" |-> list(refs(L)) ...</oattrs>
       ...</object> when L =/=Bool .List andBool L =/=Bool root

  rule <k> (. => incref(S2:#String,1)) ~> object N(_,_,(S |-> S2 => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> ref(S2) ...</oenv>
       ...</object>

  rule <k> object N(_,_,(S |-> undefined(S2) => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> undefined(S2) ...</oenv>
       ...</object>

  rule <k> (. => if IsMethod then incref("builtin-method",1) else incref("builtin-function",1) fi) ~> object N(_,_,(S |-> def S2(Min:#Int, Max:#Int, IsMethod:#Bool) => .) _,_) ...</k>
       <object>...
         <id>N</id>
         <oenv>... . => S |-> S2 ...</oenv>
       ...</object>
       (. => <object>...
         <id>S2</id>
         <oattrs> "__min__" |-> Min "__max__" |-> Max "__method__" |-> IsMethod "__class__" |-> if IsMethod then ref("builtin-method") else ref("builtin-function") fi </oattrs>
       ...</object>)
       <symbols> M:Map => M[S2 / S2] </symbols> when notBool(S2 in keys(M))

  rule <k> (. => if IsMethod then incref("builtin-method",1) else incref("builtin-function",1) fi) ~> object N(_,_,_,(S |-> def S2(Min, Max, IsMethod) => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs:Map => OAttrs[S2 / S] </oattrs>
       ...</object>
       (. => <object>...
         <id>S2</id>
         <oattrs> "__min__" |-> Min "__max__" |-> Max "__method__" |-> IsMethod "__class__" |-> if IsMethod then ref("builtin-method") else ref("builtin-function") fi </oattrs>
       ...</object>)
       <symbols> M => M[S2 / S2] </symbols> when notBool(S2 in keys(M))

  rule <k> object N(_,_,_,(S |-> K:K => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[K / S] </oattrs>
       ...</object> when getKLabel K =/=Bool 'ref`(_`) andBool getKLabel K =/=Bool 'def_`(_`,_`,_`)

  rule <k> (. => incref(S2, 1)) ~> object N(_,_,_,(S |-> ref(S2) => .) _) ...</k>
       <object>...
         <id>N</id>
         <oattrs> OAttrs => OAttrs[ref(S2) / S] </oattrs>
       ...</object>

  rule <k> object N(.,.,.,.) => . ...</k>

  rule <k> incref((ListItem(S) => .) _, N2:#Nat) ...</k>
       <references>... S |-> (N => N +Int N2) ...</references>
  rule <k> incref((ListItem(S) => .) _, N2) ...</k>
       <references>Ref:Map (. => (S |-> N2)) </references> when notBool(S in keys(Ref))
  rule incref(.List,_) => .

  rule <k> genv(S,S2) => incref(S2,1) ...</k>
       <block>...
         <blockId> 0 </blockId>
         <env>... . => #id S |-> ref(S2) ...</env>
       ...</block>

end module
