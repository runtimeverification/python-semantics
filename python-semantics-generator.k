require "python-semantics-calls.k"

module PYTHON-SEMANTICS-GENERATOR
  imports PYTHON-SEMANTICS-CALLS

  rule <k> invoke(obj(_:Int,<oattrs>... "__closure__" |-> Closure "__code__" |-> ref(Code) "__globals__" |-> Globals ...</oattrs>), M) ~> K:K => makeFrame(N, ref(Code), ref(Frame), makeLocals(ref(Code) . String2Id("co_freevars"), Closure), Globals, Globals["__builtins__"], makeCells(ref(Code) . String2Id("co_freevars"), ref(Code) . String2Id("co_cellvars"), Closure, N)) ~> mutable("gi_code" |-> ref(Code) "gi_frame" |-> ref(N), "gi_running" |-> ref("False") "gi_state" |-> .Obj, ref("generator")) ...</k>
       <nextLoc> N => N +Int 1 </nextLoc>
       <object>...
         <id>Code</id>
         <oattrs>... "co_flags" |-> Flags ...</oattrs>
       ...</object> when Flags &Int 32 =/=Int 0 [allocation]

  rule invokeBuiltin(obj("iter_generator",_), ListItem(O), .) => O
  rule invokeBuiltin(obj("next_generator",_), ListItem(O), .) => runGenerator(O, ref("None"))
  rule invokeBuiltin(obj("send_generator",_), ListItem(O) ListItem(O2), .) => runGenerator(O, O2)
  rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type), .) => ref("throw_generator")(O, Type, ref("None"), ref("None"))
  rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type) ListItem(Value), .) => ref("throw_generator")(O, Type, Value, ref("None"))
  rule invokeBuiltin(obj("throw_generator",_), ListItem(O) ListItem(Type) ListItem(Value) ListItem(Traceback), .) => test(or(istype(Traceback, ref("NoneType")), isType(Traceback, ref("traceback"))), test(or(istype(Type, ref("BaseException")), hasbases(Type, ref("BaseException"))), test(and(istype(Type, ref("BaseException")), negate(istype(Value, ref("NoneType")))), raiseInternal("TypeError", "instance exception may not have a separate value"), createRaiseStatement(O, Type, .Obj if Value is ref("None") else Value, .Obj if Traceback is ref("None") else Traceback)), raiseInternal("TypeError", "exceptions must be classes or instances deriving from BaseException")), raiseInternal("TypeError", "throw() third argument must be a traceback object"))

  syntax createRaiseStatement(Expression, Expression, Expression, Expression) [strict]

  rule createRaiseStatement(O, Type, .Obj, .Obj) => throwGenerator(O, Type)
  rule createRaiseStatement(O, Type, Value:Object, .Obj) => throwGenerator(O, Type(Value, .Arguments))
  rule createRaiseStatement(O, Type, .Obj, Traceback:Object) => test(istype(Type, ref("BaseException")), throwGenerator(O, Type . String2Id("with_traceback")(Traceback, .Arguments)), throwGenerator(O, Type(.Arguments) . String2Id("with_traceback")(Traceback, .Arguments)))
  rule createRaiseStatement(O, Type, Value:Object, Traceback:Object) => throwGenerator(O, Type(Value, .Arguments) . String2Id("with_traceback")(Traceback, .Arguments))

  rule invokeBuiltin(obj("close_generator",_), ListItem(O), .) => try: runGenerator(O, raise ref("GeneratorExit")) except ref("GeneratorExit") : ref("None") except except ref("StopIteration") : ref("None") else: raiseInternal("RuntimeError", "generator ignored GeneratorExit")

  syntax ObjRef ::= runGenerator(Expression, Expression) [strict]
                  | throwGenerator(Expression, Expression) [strict]
                  | enterGenerator(Expression, K)        
  rule runGenerator(O, Arg) => if Arg is not ref("None") : raiseInternal("TypeError", "can't send non-None value to just-started generator") else: enterGenerator(O, .K, .Obj) when getattr(O, "gi_state") ==K .Obj
  rule throwGenerator(O, Ex) => enterGenerator(O, raise Ex, getattr(O, "gi_state"))
  rule runGenerator(O, Arg) => enterGenerator(O, Arg, getattr(O, "gi_state")) when getattr(O, "gi_state") =/=K .Obj

  rule <k> (enterGenerator(O, Val, .Obj) => Val ~> getattr2(getref(O, "gi_code"), "co_code") ~> return) ~> K </k>
       <control>
         <currentFrame> Frame => id(getattr(O, "gi_frame")) </currentFrame>
         <fstack> . => (K, C, Frame, LL, ref(id(O)), XL) ...</fstack>
         <lstack> LL => . </lstack>
         <xstack> XL </xstack>
         C:Bag
       </control>

  syntax K ::= (K, Bag, List, List)
  syntax ListItem ::= (K, Bag, Int, List, Expression, List)

  rule <k> (enterGenerator(O, Val, (RestoredK, RestoredC, RestoredLL, RestoredXL)) => Val ~> RestoredK ~> return) ~> K </k>
       <control>
         <currentFrame> Frame => id(getattr(O, "gi_frame")) </currentFrame>
         <fstack> . => (K, C, Frame, LL, ref(id(O)), XL) ...</fstack>
         <lstack> LL => RestoredLL </lstack>
         <xstack> (. => RestoredXL) XL </xstack>
         (C:Bag => RestoredC)
       </control>

  rule <k> return O ~> _ => setattr(N, "gi_state", (.K, SavedC, SavedLL, SavedXL)) ~> raise ref("StopIteration")(#if id(O) ==K None #then .Arguments #else (O, .Arguments) #fi) ~> K </k>
       <control>
         <currentFrame> _ => N </currentFrame>
         <fstack> (K, C, N, LL, ref(N), XL) => . ...</fstack>
         <lstack> SavedLL => LL </lstack>
         <xstack> (SavedXL => .) XL </xstack>
         (SavedC => C)
       </control>
       <symbols>... "None" |-> None ...</symbols>

  rule <k> yield O ~> SavedK => setattr(N, "gi_state", (SavedK, SavedC, SavedLL, SavedXL)) ~> O ~> K </k>
       <control>
         <currentFrame> _ => N </currentFrame>
         <fstack> (K, C, N, LL, ref(N)) => . ...</fstack>
         <lstack> SavedLL => LL </lstack>
         <xstack> (SavedXL => .) XL </xstack>
         (SavedC => C)
       </control>

endmodule
