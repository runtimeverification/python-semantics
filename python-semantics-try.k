require "python-semantics-common.k"

module PYTHON-SEMANTICS-TRY
  imports PYTHON-SEMANTICS-COMMON

  syntax ListItem ::= try(K, K, Bag, K, Bool)

  syntax K ::= savex(Exp) [strict]
             | setcause(Exp, Exp) [strict]
             | doExcept(Exp, K, NAME) [strict(1)]
             | doExcepts(List, K, NAME)
             | doRaise(Exp, Exp, Bool) [strict(1, 2)]
             | "popfinally"
 
  rule <k> (try: Try:K ECs:K else: Else:K => Try ~> popx ~> Else) ~> K:K </k>
       <currentFrame>
         <xstack> . => try(ECs, K, C, Ex, true) ...</xstack>
         <xcontext> Ex </xcontext>
         C:Bag
       </currentFrame>

  rule <k> (try: Try finally: Finally:K => Try ~> popfinally ~> Finally) ~> K </k>
       <currentFrame>
         <xstack> (. => finally(Finally ~> raise, C, XL, LL, FL, Ex)) XL:List </xstack>
         <lstack> (. => finally(Finally, C, XL, LL, FL, Ex)) LL:List </lstack>
         <fstack> (. => finally(Finally, C, XL, LL, FL, Ex)) FL:List </fstack>
         <xcontext> Ex </xcontext>
         C:Bag
       </currentFrame>

  rule <k> popfinally => . ...</k>
       <xstack> _:ListItem => . ...</xstack>
       <lstack> _:ListItem => . ...</lstack>
       <fstack> _:ListItem => . ...</fstack>

  rule <k> popx => . ...</k> 
       <xstack> _:ListItem => . ...</xstack>

  rule <k> raise => raiseInternal("RuntimeError", "No active exception to reraise") ...</k>
       <xcontext> ref("None") </xcontext>

  rule <k> (. => ECs) ~> raise ...</k>
       <currentFrame>
         <xcontext> B </xcontext>
         <xstack> try(ECs, _, C, _, (true => false)) ...</xstack>
         (_ => C)
       </currentFrame> when B =/=K ref("None")

  rule <k> raise ~> _ => Finally </k>
       <currentFrame>
         <xcontext> B </xcontext>
         <xstack> finally(Finally, C, _, LL, FL, _) => . ...</xstack>
         <lstack> _ => LL </lstack>
         <fstack> _ => FL </fstack>
         (_ => C:Bag)
       </currentFrame> when B =/=K ref("None")

  rule <k> (. => savetb(mutable("tb_next" |-> Tb "tb_frame" |-> ref(Frame), ref("traceback")))) ~> raise ...</k>
       <currentFrame>...
         <xcontext> ref(B) </xcontext>
         <frameObject> Frame </frameObject>
         <xstack> try(_, _, _:Bag, _, false) => . ...</xstack>
       ...</currentFrame>
       <object>...
         <id>B</id>
         <oattrs>... "__traceback__" |-> Tb ...</oattrs>
       ...</object> when B =/=K "None"

  rule <k> raise ...</k>
       <control>...
         <cstack> call(Frame, C, FL, _, _) => . ...</cstack>
         <currentFrame>
           (<xstack> . </xstack>
           _ => C)
           <frameObject> _ => Frame </frameObject>
           <fstack> _ => FL </fstack>
           <xcontext> _ </xcontext>
         </currentFrame>
       ...</control>

  rule <k> EC ECs => EC ~> ECs ...</k> when notBool(getKLabel EC ==KLabel 'except:_ andBool ECs =/=K .ExceptClauses)
  rule <k> .ExceptClauses => . ...</k>

  rule <k> raise O:Object => doRaise(test(istype(O, ref("type")), O(.Arguments), O), ref("None"), true) ...</k>

  rule <k> raise O:Object from O2:Object => doRaise(test(istype(O, ref("type")), O(.Arguments), O), test(istype(O2, ref("type")), O2(.Arguments), O2), false) ...</k>

  rule <k> doRaise(O, O2, T:Bool) => test(istype(O, ref("BaseException")), test(or(id(O2) ==K NoneId,istype(O2, ref("BaseException"))), (setcause(O, O2) ~> setref(id(O), "__suppress_context__", test(T, ref("False"), test(id(O2) ==K NoneId, ref("True"), ref("False")))) ~> savex(O) ~> savetb(mutable("tb_next" |-> ref("None") "tb_frame" |-> ref(Frame), ref("traceback"))) ~> raise) , raiseInternal("TypeError", "exception causes must derive from BaseException")), raiseInternal("TypeError", "exceptions must derive from BaseException")) ...</k>
       <frameObject> Frame </frameObject>
       <symbols>... "None" |-> NoneId ...</symbols>

  rule <k> savex(obj(B,_)) => . ...</k>
       <xcontext> B2 => ref(B) </xcontext>
       <object>...
         <id>B</id>
         <oattrs> OAttrs:Map => OAttrs[B2 / "__context__"] </oattrs>
       ...</object>

  rule <k> savetb(O:Object) => setref(B, "__traceback__", O) ...</k>
       <xcontext> ref(B) </xcontext>

  rule <k> setx(Ex) => . ...</k>
       <xcontext> _ => Ex </xcontext>

  rule <k> setcause(obj(B,_), obj(B2,_)) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> OAttrs => OAttrs[ref(B2) / "__cause__"] </oattrs>
       ...</object>

  //TODO: handle traceback line numbers

  rule <k> except: Except:K ~> _ => Except ~> setx(Ex) ~> K </k>
       <currentFrame>...
         <xstack> try(_, K, _:Bag, Ex, false) => . ...</xstack>
       ...</currentFrame>

  rule except O: Except => except O as String2Id(""): Except

  rule <k> except O:Object as X:NAME : Except:K => test(hasbase(O, ref("BaseException")), doExcept(O, Except, X), test(istype(O, ref("tuple")), doExcepts(listvalue(O), Except, X), raiseInternal("TypeError", "catching classes that do not inherit from BaseException is not allowed"))) ...</k>

  rule <k> doExcepts(., Except, X) => . ...</k>
  rule <k> doExcepts(ListItem(B) L:List, Except, X) => doExcept(B, Except, X) ~> doExcepts(L, Except, X) ...</k>

  rule <k> doExcept(Type:Object, Except, X) => test(istype(B, Type), test(Id2String(X) ==String "", except: Except, (X:Target = B ~> except: (try: Except finally: unbind(X)))), .) ...</k>
       <xcontext> B:Exp </xcontext>

  syntax Exp ::= "#if" Bool "#then" Exp "#else" Exp "#fi" [function]
  rule <k> invokeBuiltin(obj("sys_exc_info",_), ., .) => tuple(#if Ex ==K ref("None") #then ref("None") #else Ex . String2Id("__class__") #fi, Ex, #if Ex ==K ref("None") 
#then ref("None") #else Ex . String2Id("__traceback__") #fi) ...</k>
       <xcontext> Ex </xcontext>

endmodule
