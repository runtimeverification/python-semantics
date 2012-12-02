require "python-semantics-common.k"

module PYTHON-SEMANTICS-TRY
  imports PYTHON-SEMANTICS-COMMON

  syntax ListItem ::= "(" K "," K "," Bag "," K "," K "," Bool ")"

  syntax K ::= savex(Expression) [strict]
             | savetb(Expression) [strict]
             | setcause(Expression, Expression) [strict]
             | doExcept(Expression, K, NAME) [strict(1)]
             | doExcepts(List, K, NAME)
             | doRaise(Expression, Expression, Bool) [strict(1, 2)]
             | "popfinally"
 
  rule <k> (try: Try:K ECs:K else: Else:K => Try ~> popx ~> Else) ~> K:K </k>
       <control>
         <xstack> . => (ECs, K, C, Ex, Tb, true) ...</xstack>
         <xcontext> Ex:K </xcontext>
         <traceback> Tb:K </traceback>
         C:Bag
       </control>

  rule <k> (try: Try finally: Finally:K => Try ~> popfinally ~> Finally) ~> K </k>
       <control>
         <xstack> (. => (Finally ~> raise, C, XL, LL, FL, Ex, Tb)) XL:List </xstack>
         <lstack> (. => (Finally, C, XL, LL, FL, Ex, Tb)) LL:List </lstack>
         <fstack> (. => (Finally, C, XL, LL, FL, Ex, Tb)) FL:List </fstack>
         <xcontext> Ex </xcontext>
         <traceback> Tb </traceback>
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
         <traceback> _ </traceback>
         <xstack> (ECs, _, C, _, _, (true => false)) ...</xstack>
         (_ => C)
       </control> when B =/=K ref("None")

  rule <k> raise ~> _ => Finally </k>
       <control>
         <xcontext> B </xcontext>
         <traceback> _ </traceback>
         <xstack> (Finally, C, _, LL, FL, _, _) => . ...</xstack>
         <lstack> _ => LL </lstack>
         <fstack> _ => FL </fstack>
         (_ => C:Bag)
       </control> when B =/=K ref("None")

  rule <k> (. => savetb(mutable("tb_next" |-> Tb "tb_frame" |-> ref(Frame), ref("traceback")))) ~> raise ...</k>
       <control>...
         <traceback> Tb </traceback>
         <currentFrame> Frame </currentFrame>
         <xstack> (_, _, _:Bag, _, _, false) => . ...</xstack>
       ...</control>

  rule <k> EC:K except ECs => EC ~> ECs ...</k> when notBool(getKLabel EC ==KLabel 'except:_ andBool ECs =/=K .ExceptClauses)
  rule <k> .ExceptClauses => . ...</k>

  rule <k> raise O:Object => doRaise(test(istype(O, ref("type")), O(.Arguments), O), ref("None"), true) ...</k>

  rule <k> raise O:Object from O2:Object => doRaise(test(istype(O, ref("type")), O(.Arguments), O), test(istype(O2, ref("type")), O2(.Arguments), O2), false) ...</k>

  rule <k> doRaise(O, O2, T:Bool) => test(istype(O, ref("BaseException")), test(or(T,istype(O2, ref("BaseException"))), (setcause(O, O2) ~> savex(O) ~> savetb(mutable("tb_next" |-> ref("None") "tb_frame" |-> ref(Frame), ref("traceback"))) ~> raise) , raiseInternal("TypeError", "exception causes must derive from BaseException")), raiseInternal("TypeError", "exceptions must derive from BaseException")) ...</k>
       <currentFrame> Frame </currentFrame>

  rule <k> savex(obj(B,_)) => . ...</k>
       <xcontext> B2 => ref(B) </xcontext>
       <object>...
         <id>B</id>
         <oattrs> OAttrs:Map => OAttrs[B2 / "__context__"] </oattrs>
       ...</object>

  rule <k> savetb(O:Object) => . ...</k>
       <traceback> _ => ref(id(O)) </traceback>

  rule <k> setx(Ex) => . ...</k>
       <xcontext> _ => Ex </xcontext>

  rule <k> setcause(obj(B,_), obj(B2,_)) => . ...</k>
       <object>...
         <id>B</id>
         <oattrs> OAttrs => OAttrs[ref(B2) / "__cause__"] </oattrs>
       ...</object>

  //TODO: handle traceback line numbers

  rule <k> except: Except:K ~> _ => Except ~> setx(Ex) ~> savetb(Tb) ~> K </k>
       <control>...
         <xstack> (_, K, _:Bag, Ex, Tb, false) => . ...</xstack>
       ...</control>

  rule except O: Except => except O as String2Id(""): Except

  rule <k> except O:Object as X:NAME : Except:K => test(hasbase(O, ref("BaseException")), doExcept(O, Except, X), test(istype(O, ref("tuple")), doExcepts(listvalue(O), Except, X), raiseInternal("TypeError", "catching classes that do not inherit from BaseException is not allowed"))) ...</k>

  rule <k> doExcepts(., Except, X) => . ...</k>
  rule <k> doExcepts(ListItem(B) L:List, Except, X) => doExcept(B, Except, X) ~> doExcepts(L, Except, X) ...</k>

  rule <k> doExcept(Type:Object, Except, X) => test(istype(B, Type), test(Id2String(X) ==String "", except: Except, (X, .Expressions := B ~> except: (try: Except finally: unbind(X)))), .) ...</k>
       <xcontext> B </xcontext>

  rule <k> invokeBuiltin(obj("sys_excinfo",_), ., .) => tuple(#if Ex ==K ref("None") #then ref("None") #else Ex . String2Id("__class__") #fi, Ex, Tb, .Expressions) ...</k>
       <xcontext> Ex </xcontext>
       <traceback> Tb </traceback>

endmodule
