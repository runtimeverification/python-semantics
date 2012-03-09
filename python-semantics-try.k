module PYTHON-SEMANTICS-TRY
  imports PYTHON-SEMANTICS-COMMON

  syntax ListItem ::= "(" K "," K "," Bag "," K "," #Bool ")"

  syntax K ::= "savex" "(" Expression ")" [:strict:]
             | "setcause" "(" Builtin "," Expression ")" [:strict(2):]
             | "doExcept" "(" Expression "," K "," NAME ")" [:strict(1):]
             | "doExcepts" "(" List "," K "," NAME ")"
             | "doRaise" "(" Expression "," Expression "," #Bool ")" [:strict(1 2):]
 
  rule <k> (try: Try:K ECs:K else: Else:K => Try ~> popx ~> Else) ~> K:K </k>
       <control>
         <xstack> . => (ECs, K, C, Ex, true) ...</xstack>
         <xcontext> Ex:K </xcontext>
         C:Bag
       </control>

  rule <k> (try: Try finally: Finally:K => Try ~> popx ~> Finally) ~> K </k>
       <control>
         <xstack> (. => (Finally, C, XL, LL, Ex)) XL:List </xstack>
         <lstack> (. => (Finally, C, XL, LL, Ex)) LL:List </lstack>
         <xcontext> Ex </xcontext>
         C:Bag
       </control>

  rule <k> popx => . ...</k> 
       <xstack> _:ListItem => . ...</xstack>

  rule <k> raise => raiseInternal("RuntimeError", "No active exception to reraise") ...</k>
       <xcontext> N:#Nat </xcontext>
       <symbols>... "None" |-> N ...</symbols>

  rule <k> (. => ECs) ~> raise ...</k>
       <control>
         <xcontext> B:Builtin </xcontext>
         <xstack> (ECs, _, C, _, (true => false)) ...</xstack>
         (_ => C)
       </control>
       <symbols>... "None" |-> N ...</symbols> when B =/=Bool N

  rule <k> (. => Finally) ~> raise ...</k>
       <control>
         <xcontext> B:Builtin </xcontext>
         <xstack> (Finally, C, _, L, _) => . ...</xstack>
         <lstack> _ => L </lstack>
         (_ => C)
       </control>
       <symbols>... "None" |-> N ...</symbols> when B =/=Bool N

  rule <k> raise ...</k>
       <control>...
         <xstack> (_, _, _:Bag, _, false) => . ...</xstack>
       ...</control>

  rule <k> EC:K except ECs => EC ~> ECs ...</k>
  rule <k> .ExceptClauses => . ...</k>

  rule <k> raise O:Object => doRaise(test(istype(O, ref("type")), O(), O), ref("None"), true) ...</k>

  rule <k> raise O from O2:Object => doRaise(test(istype(O, ref("type")), O(), O), test(istype(O2, ref("type")), O2(), O2), false) ...</k>

  rule <k> doRaise(O, O2, T:#Bool) => test(istype(O, ref("BaseException")), test(or(T,istype(O2, ref("BaseException"))), (setcause(O, O2) ~> savex(O) ~> raise) , raiseInternal("TypeError", "exception causes must derive from BaseException")), raiseInternal("TypeError", "exceptions must derive from BaseException")) ...</k>

  rule <k> savex(obj(B,_)) => . ...</k>
       <xcontext> B2:Builtin => B </xcontext>
       <object>...
         <id>B</id>
         <oattrs> OAttrs:Map => OAttrs[B2 / "__context__"] </oattrs>
       ...</object>

  rule <k> setx(Ex) => . ...</k>
       <xcontext> _ => Ex </xcontext>

  rule <k> setcause(obj(B,_), obj(B2,_)) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> OAttrs => OAttrs[B2 / "__cause__"] </oattrs>
       ...</object>

  //TODO: handle traceback

  rule <k> except: Except:K ~> _ => Except ~> setx(Ex) ~> K </k>
       <control>...
         <xstack> (_, K, _:Bag, Ex, false) => . ...</xstack>
       ...</control>

  rule <k> except O: Except => except O as .Obj: Except ...</k>

  rule <k> except O as X:NAME : Except => test(hasbase(O, ref("BaseException")), doExcept(O, Except, X), test(istype(O, ref("tuple")), doExcepts(listvalue(O), Except, X), raiseInternal("TypeError", "catching classes that do not inherit from BaseException is not allowed"))) ...</k>

  rule <k> doExcepts(., Except, X) => . ...</k>
  rule <k> doExcepts(ListItem(B:Builtin) L:List, Except, X) => doExcept(ref(B), Except, X) ~> doExcepts(L, Except, X) ...</k>

  //TODO: sys.exc_info
  rule <k> doExcept(Type:Object, Except, X) => test(istype(ref(B), Type), test(X ==Bool .Obj, except: Except, (bind(X, B) ~> except: (try: Except finally: del (X, .List{","})))), .) ...</k>
       <xcontext> B:Builtin </xcontext>

  //TODO: SyntaxError for non-last except block
end module
