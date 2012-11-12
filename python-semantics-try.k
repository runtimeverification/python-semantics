require "python-semantics-common.k"

module PYTHON-SEMANTICS-TRY
  imports PYTHON-SEMANTICS-COMMON

  syntax ListItem ::= "(" K "," K "," Bag "," K "," Bool ")"

  syntax K ::= "savex" "(" Expression ")" [strict]
             | "setcause" "(" Expression "," Expression ")" [strict]
             | "doExcept" "(" Expression "," K "," NAME ")" [strict(1)]
             | "doExcepts" "(" List "," K "," NAME ")"
             | "doRaise" "(" Expression "," Expression "," Bool ")" [strict(1 2)]
             | "popfinally"
 
  rule <k> (try: Try:K ECs:K else: Else:K => Try ~> popx ~> Else) ~> K:K </k>
       <control>
         <xstack> . => (ECs, K, C, Ex, true) ...</xstack>
         <xcontext> Ex:K </xcontext>
         C:Bag
       </control>

  rule <k> (try: Try finally: Finally:K => Try ~> popfinally ~> Finally) ~> K </k>
       <control>
         <xstack> (. => (Finally, C, XL, LL, FL, Ex)) XL:List </xstack>
         <lstack> (. => (Finally, C, XL, LL, FL, Ex)) LL:List </lstack>
         <fstack> (. => (Finally, C, XL, LL, FL, Ex)) FL:List </fstack>
         <xcontext> Ex </xcontext>
         C:Bag
       </control>

  rule <k> popfinally => . ...</k>
       <xstack> _:ListItem => . ...</xstack>
       <lstack> _:ListItem => . ...</lstack>
       <fstack> _:ListItem => . ...</fstack>

  rule <k> popx => . ...</k> 
       <xstack> _:ListItem => . ...</xstack>

  rule <k> raise => raiseInternal("RuntimeError", "No active exception to reraise") ...</k>
       <xcontext> ref("None") </xcontext>

  rule <k> (. => ECs) ~> raise ...</k>
       <control>
         <xcontext> B </xcontext>
         <xstack> (ECs, _, C, _, (true => false)) ...</xstack>
         (_ => C)
       </control> when B =/=K ref("None")

  rule <k> (. => Finally) ~> raise ...</k>
       <control>
         <xcontext> B </xcontext>
         <xstack> (Finally, C, _, LL, FL, _) => . ...</xstack>
         <lstack> _ => LL </lstack>
         <fstack> _ => FL </fstack>
         (_ => C)
       </control> when B =/=K ref("None")

  rule <k> raise ...</k>
       <control>...
         <xstack> (_, _, _:Bag, _, false) => . ...</xstack>
       ...</control>

  rule <k> EC:K except ECs => EC ~> ECs ...</k> when notBool(getKLabel EC ==KLabel 'except:_ andBool ECs =/=K .ExceptClauses)
  rule <k> .ExceptClauses => . ...</k>

  rule <k> raise O:Object => doRaise(test(istype(O, ref("type")), O(.Arguments), O), ref("None"), true) ...</k>

  rule <k> raise O:Object from O2:Object => doRaise(test(istype(O, ref("type")), O(.Arguments), O), test(istype(O2, ref("type")), O2(.Arguments), O2), false) ...</k>

  rule <k> doRaise(O, O2, T:Bool) => test(istype(O, ref("BaseException")), test(or(T,istype(O2, ref("BaseException"))), (setcause(O, O2) ~> savex(O) ~> raise) , raiseInternal("TypeError", "exception causes must derive from BaseException")), raiseInternal("TypeError", "exceptions must derive from BaseException")) ...</k>

  rule <k> savex(obj(B,_)) => . ...</k>
       <xcontext> B2 => ref(B) </xcontext>
       <object>...
         <id>B</id>
         <oattrs> OAttrs:Map => OAttrs[B2 / "__context__"] </oattrs>
       ...</object>

  rule <k> setx(Ex) => . ...</k>
       <xcontext> _ => Ex </xcontext>

  rule <k> setcause(obj(B,_), obj(B2,_)) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> OAttrs => OAttrs[ref(B2) / "__cause__"] </oattrs>
       ...</object>

  //TODO: handle traceback

  rule <k> except: Except:K ~> _ => Except ~> setx(Ex) ~> K </k>
       <control>...
         <xstack> (_, K, _:Bag, Ex, false) => . ...</xstack>
       ...</control>

  rule except O: Except => except O as String2Id(""): Except

  rule <k> except O:Object as X:NAME : Except:K => test(hasbase(O, ref("BaseException")), doExcept(O, Except, X), test(istype(O, ref("tuple")), doExcepts(listvalue(O), Except, X), raiseInternal("TypeError", "catching classes that do not inherit from BaseException is not allowed"))) ...</k>

  rule <k> doExcepts(., Except, X) => . ...</k>
  rule <k> doExcepts(ListItem(B) L:List, Except, X) => doExcept(B, Except, X) ~> doExcepts(L, Except, X) ...</k>

  //TODO: sys.exc_info
  rule <k> doExcept(Type:Object, Except, X) => test(istype(B, Type), test(Id2String(X) ==String "", except: Except, (X, .Expressions := B ~> except: (try: Except finally: unbind(X)))), .) ...</k>
       <xcontext> B </xcontext>

endmodule
