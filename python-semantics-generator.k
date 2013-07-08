require "python-semantics-calls.k"

module PYTHON-SEMANTICS-GENERATOR
  imports PYTHON-SEMANTICS-CALLS

  rule [invoke-generator-function]: <k> invoke(obj(_:Int,<oattrs>... "__closure__" |-> Closure "__code__" |-> ref(Code) "__globals__" |-> Globals ...</oattrs>), M) ~> K:K => makeFrame(N, ref(Code), ref("None"), makeLocals(ref(Code) . String2Id("co_freevars"), Closure), Globals, Globals["__builtins__"], makeCells(ref(Code) . String2Id("co_freevars"), ref(Code) . String2Id("co_cellvars"), Closure, N), M) ~> mutable("gi_code" |-> ref(Code) "gi_frame" |-> ref(N) "gi_running" |-> ref("False") "gi_state" |-> .K, ref("generator")) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <object>...
         <id>Code</id>
         <oattrs>... "co_flags" |-> Flags ...</oattrs>
       ...</object> when Flags &Int 32 =/=Int 0 [allocation]

  rule invokeBuiltin(obj("iter_generator",_), ListItem(O), .) => O
  rule invokeBuiltin(obj("next_generator",_), ListItem(O), .) => runGenerator(ref(id(O)), ref("None"))
  rule invokeBuiltin(obj("send_generator",_), ListItem(O) ListItem(O2), .) => runGenerator(ref(id(O)), O2)
  rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type), .) => ref("throw_generator")(O, Type, ref("None"), ref("None"))
  rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type) ListItem(Value), .) => ref("throw_generator")(O, Type, Value, ref("None"))
  rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type) ListItem(Value) ListItem(Traceback), .) => test(or(istype(Traceback, ref("NoneType")), istype(Traceback, ref("traceback"))), test(or(istype(Type, ref("BaseException")), hasbase(Type, ref("BaseException"))), test(and(istype(Type, ref("BaseException")), negate(istype(Value, ref("NoneType")))), raiseInternal("TypeError", "instance exception may not have a separate value"), createRaiseStatement(O, Type, .Obj if Value is ref("None") else Value, .Obj if Traceback is ref("None") else Traceback)), raiseInternal("TypeError", "exceptions must be classes or instances deriving from BaseException")), raiseInternal("TypeError", "throw() third argument must be a traceback object"))

  syntax ObjRef ::= createRaiseStatement(Exp, Exp, Exp, Exp) [strict]

  rule createRaiseStatement(O, Type, .Obj, .Obj) => throwGenerator(ref(id(O)), test(istype(Type, ref("BaseException")), Type, Type(.Arguments)))
  rule createRaiseStatement(O, Type, Value:Object, .Obj) => throwGenerator(ref(id(O)), Type(Value))
  rule createRaiseStatement(O, Type, .Obj, Traceback:Object) => test(istype(Type, ref("BaseException")), throwGenerator(ref(id(O)), Type . String2Id("with_traceback")(Traceback)), throwGenerator(ref(id(O)), Type(.Arguments) . String2Id("with_traceback")(Traceback)))
  rule createRaiseStatement(O, Type, Value:Object, Traceback:Object) => throwGenerator(ref(id(O)), Type(Value) . String2Id("with_traceback")(Traceback))

  rule invokeBuiltin(obj("close_generator",_), ListItem(O), .) => try: throwGenerator(ref(id(O)), ref("GeneratorExit")) ; except ref("GeneratorExit") : ref("None") except ref("StopIteration") : ref("None") else: raiseInternal("RuntimeError", "generator ignored GeneratorExit")

  syntax ObjRef ::= runGenerator(Exp, Exp) [seqstrict(2, 1)]
                  | throwGenerator(Exp, Exp) [seqstrict(2, 1)]
                  | enterGenerator(Exp, K, K)
  rule runGenerator(O:Object, Arg:Object) => if Arg is not ref("None") : raiseInternal("TypeError", "can't send non-None value to just-started generator") else: enterGenerator(O, .K, .K) when getattr(O, "gi_state") ==K .K
  rule throwGenerator(O:Object, Ex:Object) => enterGenerator(O, raise Ex, getattr(O, "gi_state"))
  rule runGenerator(O:Object, Arg:Object) => enterGenerator(O, Arg, getattr(O, "gi_state")) when getattr(O, "gi_state") =/=K .K

  syntax K ::= beginRunningGenerator(Object)
  rule beginRunningGenerator(O) => if getref(O, "gi_running"): raiseInternal("ValueError", "generator already executing") ~> setref(id(O), "gi_running", ref("True"))

  rule [start-generator]: <k> enterGenerator(O, Val, .K) ~> K => beginRunningGenerator(O) ~> Val ~> getattr2(getref(O, "gi_code"), "co_code") ~> return </k>
       <control>...
         <currentFrame>
           <frameObject> Frame => id(getattr(O, "gi_frame")) </frameObject>
           <fstack> FL => . </fstack>
           <xcontext> XC </xcontext>
           (C:Bag => <xstack> .List </xstack> <lstack> .List </lstack>)
         </currentFrame>
         <cstack> . => ListItem(generator(Frame, C, FL, XC, K, ref(id(O)))) ...</cstack>
       ...</control>

  syntax K ::= (K, CurrentFrameCellFragment, List, K)

  rule [continue-generator]: <k> enterGenerator(O, Val, (RestoredK, RestoredC, RestoredFL, RestoredXC)) ~> K => beginRunningGenerator(O) ~> Val ~> RestoredK ~> return </k>
       <control>...
         <currentFrame>
           <frameObject> Frame => id(getattr(O, "gi_frame")) </frameObject>
           <fstack> FL => RestoredFL </fstack>
           <xcontext> XC => RestoredXC </xcontext>
           (C:Bag => RestoredC)
         </currentFrame>
         <cstack> . => ListItem(generator(Frame, C, FL, XC, K, ref(id(O)))) ...</cstack>
       ...</control>

  syntax Arguments ::= "#if" Bool "#then" Arguments "#else" Arguments "#fi" [function]
  rule <k> return O:Object ~> _ => setref(N, "gi_running", ref("False")) ~> setattr(N, "gi_state", (#freezer (HOLE ;)(.KList), SavedC, .List, SavedXC)) ~> raise ref("StopIteration")(#if id(O) ==K NoneId #then .Arguments #else O #fi) ~> K </k>
       <control>...
         <cstack> ListItem(generator(Frame, C, FL, XC, K, ref(N))) => . ...</cstack>
         <currentFrame>
           <frameObject> _ => Frame </frameObject>
           <fstack> . => FL </fstack>
           <xcontext> SavedXC => XC </xcontext>
           (SavedC => C)
         </currentFrame>
       ...</control>
       <symbols>... "None" |-> NoneId ...</symbols>

  rule [yield]: <k> yield O ~> SavedK => setref(N, "gi_running", ref("False")) ~> setattr(N, "gi_state", (SavedK, SavedC, SavedFL, SavedXC)) ~> O ~> K </k>
       <control>...
         <cstack> ListItem(generator(Frame, C, FL, XC, K, ref(N))) => . ...</cstack>
         <currentFrame>
           <frameObject> _ => Frame </frameObject>
           <fstack> SavedFL => FL </fstack>
           <xcontext> SavedXC => XC </xcontext>
           (SavedC => C)
         </currentFrame>
       </control>

  rule [raise-out-of-generator]: <k> (. => setref(N, "gi_running", ref("False")) ~> setattr(N, "gi_state", (#freezer (HOLE ;)(.KList), <xstack> . </xstack> SavedC, .List, ref("None")))) ~> raise ...</k>
       <control>...
         <cstack> ListItem(generator(Frame, C, FL, _, _, ref(N))) => . ...</cstack>
         <currentFrame>
           (<xstack> . </xstack>
           SavedC => C)
           <frameObject> _ => Frame </frameObject>
           <fstack> . => FL </fstack>
           <xcontext> SavedXC </xcontext>
         </currentFrame>
       ...</control>

endmodule
