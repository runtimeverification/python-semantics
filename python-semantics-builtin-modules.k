require "python-semantics-common.k"


module PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-COMMON

  syntax K ::= "builtins"
             | "resolve"
             | "modules"
             | "importlib"
             | "object" ObjId "(" String "," List "," Map "," Map ")"
             | "incref" "(" List "," Int ")"
             | "incref" "(" ObjId "," Int ")"
             | "genv" "(" String "," String ")"
             | "module" ObjId "(" Exp ")" [strict(2)]
             | "struct" ObjId "(" Exps ")"

  syntax ObjRef ::= "def" String "(" Int "," Int "," Bool ")"

  syntax ListItem ::= "refs" "(" List ")"

  rule incref(B:ObjId,N) => incref(ListItem(B),N) [macro]
  rule refs(ListItem(S) L) => ListItem(ref(S)) refs(L)
  rule refs(.List) => .List

  syntax K ::= "bootstrap" | saveConfiguration(Int, String) | loadConfiguration(Int, String) | loadConfigurationByte(K)
  rule <k> initialize(bootstrap) => builtins ~> resolve ~> modules ~> importlib ~> saveConfiguration(#open("file:bootstrapped.bin"), .K) ...</k>
  //the semantics of sys.path is that the first element is "" for the interpreter and the directory containing the file being executed if a file is being executed
  rule <k> initialize(Program:K) => loadConfiguration(#open("file:bootstrapped.bin\001r"), "") ~> ref("sys") . String2Id("path") [ 0 ] = SysPath:String ~> executeModule(codeObject(String2Id("__main__"), .Parameters, Program, true), ref("builtins"), {.KeyData}) ...</k>
       <sysPath> ListItem(SysPath) ...</sysPath> when Program =/=K bootstrap

  syntax String ::= TCellFragment2String(TCellFragment) [function, hook(#K-PRINTER:bag2string)]
  syntax TCellFragment ::= String2TCellFragment(String) [function, hook(#K-PARSER:string2bag)]

  rule <T>
         <k> saveConfiguration(Fd:Int, (.K => TCellFragment2String(B))) ...</k>
         B:Bag
       </T>
  rule (. => #fPutBytes(Fd, substrString(S, 0, 1000))) ~> saveConfiguration(Fd:Int, (S:String => substrString(S, 1000, lengthString(S)))) when S =/=String ""
  rule saveConfiguration(Fd:Int, "") => #close(Fd)
  rule (. => loadConfigurationByte(#fReadBytes(Fd, 1000))) ~> loadConfiguration(Fd:Int, _)
  rule (loadConfigurationByte(S2:String) => .) ~> loadConfiguration(Fd:Int, (S:String => S +String S2))
  rule loadConfigurationByte(#EOF) ~> loadConfiguration(Fd:Int, S:String) => doLoadConfiguration(String2TCellFragment(S))

  syntax K ::= doLoadConfiguration(TCellFragment)
  rule <T>
         <k> doLoadConfiguration(C) ...</k>
         (_:Bag => C)
       </T>

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

  context object N(_, _, (S |-> HOLE) _, _) when getKLabel HOLE =/=KLabel 'ref`(_`)

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

  rule <k> module S(O:Object) => ref(N) . String2Id("__dict__") ["__name__"] = S:String ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__dict__" |-> ref(id(O)) "__class__" |-> ref("module") </oattrs>
       ...</object>)
       <symbols>... (. => S |-> N) ...</symbols>
       <builtinModules>... (. => S |-> N) ...</builtinModules> [allocation]

  rule <k> (. => incref(N, 3)) ~> struct (S:String => N)(K) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       (. => <object>...
         <id>N</id>
         <oattrs> "__class__" |-> ref("type") "__bases__" |-> list(ListItem(ref("tuple"))) "__order__" |-> list(.List) "__name__" |-> S "__mro__" |-> . </oattrs>
         <oenv> "__new__" |-> ref("new_structseq") </oenv>
       ...</object>)
       <symbols>... (. => S |-> N) ...</symbols> [allocation]

  rule <k> (. => object S +String "_structseq"("attribute", ., ., "__get__" |-> "__value__"[lengthList L])) ~> struct N:Int((S:String , K) => K) ...</k>
       <object>...
         <id>N</id>
         <oattrs>... "__order__" |-> list(L (. => ListItem(S))) ...</oattrs>
         <oenv>... . => S |-> ref(S +String "_structseq") ...</oenv>
       ...</object>

  rule struct _(.Exps) => .

endmodule
