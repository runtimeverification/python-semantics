require "python-semantics-calls.k"

module PYTHON-SEMANTICS-GENERATOR
  imports PYTHON-SEMANTICS-CALLS

  rule [invoke-generator-function]: <k> invoke(obj(_:Int,<oattrs>... "__closure__" |-> Closure "__code__" |-> ref(Code) "__globals__" |-> Globals ...</oattrs>), M) ~> K:K => makeFrame(N, ref(Code), ref("None"), makeLocals(ref(Code) . String2Id("co_freevars"), Closure), Globals, Globals["__builtins__"], makeCells(ref(Code) . String2Id("co_freevars"), ref(Code) . String2Id("co_cellvars"), Closure, N), M, false) ~> mutable("gi_code" |-> ref(Code) "gi_frame" |-> ref(N) "gi_running" |-> ref("False") "gi_state" |-> .K, ref("generator")) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <object>...
         <id>Code</id>
         <oattrs>... "co_flags" |-> Flags ...</oattrs>
       ...</object> when Flags &Int 32 =/=Int 0 [allocation]

  //rule invokeBuiltin(obj("iter_generator",_), ListItem(O), .) => O
  //rule invokeBuiltin(obj("next_generator",_), ListItem(O), .) => runGenerator(O, ref("None"))
  //rule invokeBuiltin(obj("send_generator",_), ListItem(O) ListItem(O2), .) => runGenerator(O, O2)
  //rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type), .) => ref("throw_generator")(O, Type, ref("None"), ref("None"))
  //rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type) ListItem(Value), .) => ref("throw_generator")(O, Type, Value, ref("None"))
  //rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type) ListItem(Value) ListItem(Traceback), .) => test(or(istype(Traceback, ref("NoneType")), istype(Traceback, ref("traceback"))), test(or(istype(Type, ref("BaseException")), hasbase(Type, ref("BaseException"))), test(and(istype(Type, ref("BaseException")), negate(istype(Value, ref("NoneType")))), raiseInternal("TypeError", "instance exception may not have a separate value"), createRaiseStatement(O, Type, .Obj if Value is ref("None") else Value, .Obj if Traceback is ref("None") else Traceback)), raiseInternal("TypeError", "exceptions must be classes or instances deriving from BaseException")), raiseInternal("TypeError", "throw() third argument must be a traceback object"))

  syntax ObjRef ::= createRaiseStatement(Expression, Expression, Expression, Expression) [strict]

  rule createRaiseStatement(O, Type, .Obj, .Obj) => throwGenerator(O, Type)
  rule createRaiseStatement(O, Type, Value:Object, .Obj) => throwGenerator(O, Type(Value, .Arguments))
  rule createRaiseStatement(O, Type, .Obj, Traceback:Object) => test(istype(Type, ref("BaseException")), throwGenerator(O, Type . String2Id("with_traceback")(Traceback, .Arguments)), throwGenerator(O, Type(.Arguments) . String2Id("with_traceback")(Traceback, .Arguments)))
  rule createRaiseStatement(O, Type, Value:Object, Traceback:Object) => throwGenerator(O, Type(Value, .Arguments) . String2Id("with_traceback")(Traceback, .Arguments))

  //rule invokeBuiltin(obj("close_generator",_), ListItem(O), .) => try: throwGenerator(O, ref("GeneratorExit")) ; except ref("GeneratorExit") : ref("None") except except ref("StopIteration") : ref("None") else: raiseInternal("RuntimeError", "generator ignored GeneratorExit")

  syntax ObjRef ::= runGenerator(Expression, Expression) [strict]
                  | throwGenerator(Expression, Expression) [strict]
                  | enterGenerator(Expression, K, K)
  rule runGenerator(O, Arg) => if Arg is not ref("None") : raiseInternal("TypeError", "can't send non-None value to just-started generator") else: enterGenerator(O, .K, .K) when getattr(O, "gi_state") ==K .K
  rule throwGenerator(O, Ex) => enterGenerator(O, raise Ex, getattr(O, "gi_state"))
  rule runGenerator(O, Arg) => enterGenerator(O, Arg, getattr(O, "gi_state")) when getattr(O, "gi_state") =/=K .K

  rule [start-generator]: <k> enterGenerator(O, Val, .K) ~> K => Val ~> getattr2(getref(O, "gi_code"), "co_code") ~> return </k>
       <control>...
         <currentFrame>
           <frameObject> Frame => getattr(O, "gi_frame") </frameObject>
           <fstack> FL => . </fstack>
           <xcontext> XC </xcontext>
           (C:Bag => newFrame)
         </currentFrame>
         <cstack> . => generator(Frame, C, FL, XC, K, id(O)) ...</cstack>
       ...</control>

  syntax K ::= (K, Bag, List, K)

  rule [continue-generator]: <k> enterGenerator(O, Val, (RestoredK, RestoredC, RestoredFL, RestoredXC)) ~> K => Val ~> RestoredK ~> return </k>
       <control>...
         <currentFrame>
           <frameObject> Frame => getattr(O, "gi_frame") </frameObject>
           <fstack> FL => RestoredFL </fstack>
           <xcontext> XC => RestoredXC </xcontext>
           (C:Bag => RestoredC)
         </currentFrame>
         <cstack> . => generator(Frame, C, FL, XC, K, id(O)) ...</cstack>
       ...</control>

  rule <k> return O ~> _ => setattr(N, "gi_state", (#freezer (HOLE ;)(.KList), SavedC, .List, SavedXC)) ~> raise ref("StopIteration")(#if id(O) ==K None #then .Arguments #else (O, .Arguments) #fi) ~> K </k>
       <control>...
         <cstack> generator(Frame, C, FL, XC, K, N) => . ...</cstack>
         <currentFrame>
           <frameObject> _ => Frame </frameObject>
           <fstack> . => FL </fstack>
           <xcontext> SavedXC => XC </xcontext>
           (SavedC => C)
         </currentFrame>
       ...</control>
       <symbols>... "None" |-> None ...</symbols>

  rule [yield]: <k> yield O ~> SavedK => setattr(N, "gi_state", (SavedK, SavedC, SavedFL, SavedXC)) ~> O ~> K </k>
       <control>...
         <cstack> generator(Frame, C, FL, XC, K, N) => . ...</cstack>
         <currentFrame>
           <frameObject> _ => Frame </frameObject>
           <fstack> SavedFL => FL </fstack>
           <xcontext> SavedXC => XC </xcontext>
           (SavedC => C)
         </currentFrame>
       </control>

  rule [raise-out-of-generator]: <k> (. => setattr(N, "gi_state", (#freezer (HOLE ;)(.KList), <xstack> . </xstack> SavedC, .List, ref("None")))) ~> raise ...</k>
       <control>...
         <cstack> generator(Frame, C, FL, _, _, N) => . ...</cstack>
         <currentFrame>
           (<xstack> . </xstack>
           SavedC => C)
           <frameObject> _ => Frame </frameObject>
           <fstack> . => FL </fstack>
           <xcontext> SavedXC </xcontext>
         </currentFrame>
       ...</control>

endmodule
