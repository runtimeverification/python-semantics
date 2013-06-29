require "python-semantics-calls.k"
require "python-visitor.k"

module PYTHON-SEMANTICS-BUILTIN-FUNCTIONS
  imports PYTHON-SEMANTICS-CALLS
  imports PYTHON-VISITOR

  syntax K ::= doAll(Exp) [strict]
             | doAny(Exp) [strict]

  rule invokeBuiltin(obj("abs",_), ListItem(O:Object), .) => getmember(O, "__abs__", true, false, false)(.Arguments) -> raiseInternal("TypeError", "bad operand type for abs()")

  rule invokeBuiltin(obj("all",_), ListItem(O:Object), .) => try: doAll(ref("iter")(O)) except ref("StopIteration"): ref("True") else: pass
  rule doAll(Iter:Object) => if not getmember(Iter, "__next__", true, false, true)(.Arguments) : ref("False") else: doAll(Iter)

  rule invokeBuiltin(obj("any",_), ListItem(O:Object), .) => try: doAny(ref("iter")(O)) except ref("StopIteration"): ref("False") else: pass
  rule doAny(Iter:Object) => if getmember(Iter, "__next__", true, false, true)(.Arguments) : ref("True") else: doAny(Iter)

  rule invokeBuiltin(obj("callable",_), ListItem(O:Object), .) => bool(hasmember(O, "__call__", false))

  rule invokeBuiltin(obj("super.__new__",_), ListItem(Cls) L:List, .) => newHelper(Cls, ref("super"), .) ~> mutable("__self__" |-> ref("None") "__self_class__" |-> ref("None") "__thisclass__" |-> ref("None"), Cls)
  rule <k> invokeBuiltin(obj("super.__init__",_), ListItem(O), .) => #if ArgCount >Int 0 #then if VarNames[0] in Locals: if "__class__" in Cells: test(getattr2(Cells["__class__"], "cell_contents") =/=Obj .Obj, test(istype(getref2(Cells["__class__"], "cell_contents"), ref("type")), ref("super.__init__")(O, getref2(Cells["__class__"], "cell_contents"), Locals[VarNames[0]]), raiseInternal("SystemError", "super(): __class__ is not a type")), raiseInternal("SystemError", "super(): empty __class__ cell")) else: raiseInternal("SystemError", "super(): __class__ cell not found") else: raiseInternal("SystemError", "super(): arg[0] deleted") #else raiseInternal("SystemError", "super(): no arguments") #fi ...</k>
       <frameObject> N </frameObject>
       <object>...
         <id> N </id>
         <oattrs>... "f_code" |-> ref(N2) "f_cells" |-> Cells "f_locals" |-> Locals ...</oattrs>
       ...</object>
       <object>...
         <id> N2 </id>
         <oattrs>... "co_argcount" |-> ArgCount "co_varnames" |-> VarNames ...</oattrs>
       ...</object>
  rule invokeBuiltin(obj("super.__init__",_), ListItem(O) ListItem(ThisClass), .) => ref("super.__init__")(O, ThisClass, ref("None"))
  rule invokeBuiltin(obj("super.__init__",_), ListItem(O) ListItem(ThisClass) ListItem(Self), .) => test(istype(ThisClass, ref("type")), setref(id(O), "__thisclass__", ThisClass), raiseInternal("TypeError", "must be type")) ~> test(istype(Self, ThisClass) or hasbase(Self, ThisClass) or Self is None, setref(id(O), "__self__", Self), raiseInternal("TypeError", "super(type, obj): obj must be instance or subtype of type")) ~> test(istype(Self, ThisClass), setref(id(O), "__self_class__", getref(Self, "__class__")), test(hasbase(Self, ThisClass), setref(id(O), "__self_class__", Self), setref(id(O), "__self_class__", ref("None")))) ~> ref("None")

  rule invokeBuiltin(obj("reversed.__new__",_), ListItem(Cls) ListItem(Sequence:Object), .) => newHelper(Cls, ref("reversed"), .) ~> test(hasmember(Sequence, "__getitem__", false), makeReversed(Cls, Sequence, ref("len")(Sequence)), raiseInternal("TypeError", "argument to reversed() must be a sequence"))
  syntax Exp ::= makeReversed(Exp, Exp, Exp) [strict]
  rule makeReversed(Cls, Sequence, Len:Object) => mutable("__state__" |-> intvalue(Len) -Int 1 "__value__" |-> Sequence, Cls)
  rule invokeBuiltin(obj("reversed.__iter__",_), ListItem(Self), .) => Self
  rule invokeBuiltin(obj("reversed.__next__",_), ListItem(Self), .) => setattr(id(Self), "__state__", getattr(Self, "__state__") -Int 1) ~> getref(Self, "__value__")[getattr(Self, "__state__")] when getattr(Self, "__state__") >=Int 0
  rule invokeBuiltin(obj("reversed.__next__",_), ListItem(Self), .) => raise ref("StopIteration") when getattr(Self, "__state__") <Int 0

  rule invokeBuiltin(obj("compile",_), ListItem(Source) ListItem(Filename) ListItem(Mode), .) => ref("compile")(Source, Filename, Mode, 0, ref("False"), -1)
  rule invokeBuiltin(obj("compile",_), ListItem(Source) ListItem(Filename) ListItem(Mode) ListItem(Flags), .) => ref("compile")(Source, Filename, Mode, Flags, ref("False"), -1)
  rule invokeBuiltin(obj("compile",_), ListItem(Source) ListItem(Filename) ListItem(Mode) ListItem(Flags) ListItem(DontInherit), .) => ref("compile")(Source, Filename, Mode, Flags, DontInherit, -1)
  rule invokeBuiltin(obj("compile",_), ListItem(Source) ListItem(Filename) ListItem(Mode), "dont_inherit" |-> DontInherit) => ref("compile")(Source, Filename, Mode, 0, DontInherit, -1)
  rule <k> invokeBuiltin(obj("compile",_), ListItem(Source) ListItem(Filename) ListItem(Mode) ListItem(Flags) ListItem(DontInherit) ListItem(Optimize), .) =>
  test(istype(Filename, ref("str")), .K, raiseInternal("TypeError", "Can't convert object to str implicitly")) ~>
  test(istype(Mode, ref("str")), .K, raiseInternal("TypeError", "compile() arg 3 must be str")) ~>
  test(istype(Flags, ref("int")), .K, raiseInternal("TypeError", "an integer is required")) ~>
  test(istype(DontInherit, ref("int")), .K, raiseInternal("TypeError", "an integer is required")) ~>
  test(istype(Optimize, ref("int")), .K, raiseInternal("TypeError", "an integer is required")) ~>
  test(intvalue(Flags) =/=Int 0, ?Futures:Stmt, .K) ~>
  test(intvalue(Optimize) <Int -1 orBool intvalue(Optimize) >Int 2, raiseInternal("ValueError", "compile(): invalid optimize value"), .K) ~>
  test(intvalue(Optimize) >=Int 0, setOptimize(intvalue(Optimize)), .K) ~>
  test(strvalue(Mode) =/=String "exec" andBool strvalue(Mode) =/=String "eval" andBool strvalue(Mode) =/=String "single", raiseInternal("ValueError", "compile() arg 3 must be 'exec', 'eval' or 'single'"), .K) ~>
  test(istype(Source, ref("AST")), ?AST:Stmt, .K) ~>
  test(hasattr(Source, "__value__") andBool (isString(getattr(Source, "__value__")) ==K true), .K, raiseInternal("TypeError", "compile() arg 1 must be a string or read buffer")) ~>
  test(findString(strvalue(Source), "\000", 0) =/=Int -1, raiseInternal("TypeError", "source code string cannot contain null bytes"), .K) ~>
  parseAndCompile(strvalue(Source), strvalue(Filename), strvalue(Mode)) ~> setOptimize(CurrentOptimize)...</k>
  <constants> Constants:Map </constants>
  <optimize> CurrentOptimize </optimize>
  
  syntax K ::= setOptimize(Int)
  rule <k> setOptimize(I) => . ...</k>
       <optimize> _ => I </optimize>
  rule <k> O:Object ~> setOptimize(I) => O ...</k>
       <optimize> _ => I </optimize>

  syntax Exp ::= parseAndCompile(String, String, String)
  rule [parseAndCompile]: parseAndCompile(Source, _, "eval") => compile(return #parse(Source, "Exp"), "eval")
  rule parseAndCompile(Source, _, "exec") => compile(#parse(Source, "Stmts"), "exec")
  rule parseAndCompile(Source, _, "single") => visit(#parse(Source, "Stmt"), 'singleVisitor) ~> compile(., "single")
  syntax Exp ::= compile(K, String)
  syntax K ::= singleVisitor(KLabel, Int, K)
  rule singleVisitor('Expr, 0, K) => visited(ref("sys.displayhook")(K ::Exp))
  rule singleVisitor(Lbl, N, K) => visit(K, 'singleVisitor) when notBool(Lbl ==KLabel 'Expr) andBool N =/=Int -1
  rule singleVisitor(returner, -1, K) => visited(K)
  rule (visited(K) => .) ~> compile((_ => K),_)
  rule compile(#noparse,_) => raiseInternal("SyntaxError", "invalid syntax")
  rule compile(return #noparse::K, _) => raiseInternal("SyntaxError", "invalid syntax")
  rule compile(K, S) => codeObject(String2Id("<module>"), .Parameters, K, #if S ==String "eval" #then funcobject #else moduleobject #fi) when K =/=K #noparse

  rule invokeBuiltin(obj("eval",_), ListItem(Expression), .) => ref("eval")(Expression, ref("None"), ref("None"))
  rule invokeBuiltin(obj("eval",_), ListItem(Expression) ListItem(Globals), .) => ref("eval")(Expression, Globals, ref("None"))
  rule invokeBuiltin(obj("eval",_), ListItem(Expression) ListItem(Globals) ListItem(Locals), .) => doExecOrEval(Expression, Globals, Locals, "eval")
  rule invokeBuiltin(obj("exec",_), ListItem(Expression), .) => ref("exec")(Expression, ref("None"), ref("None"))
  rule invokeBuiltin(obj("exec",_), ListItem(Expression) ListItem(Globals), .) => ref("exec")(Expression, Globals, ref("None"))
  rule invokeBuiltin(obj("exec",_), ListItem(Expression) ListItem(Globals) ListItem(Locals), .) => doExecOrEval(Expression, Globals, Locals, "exec")
  syntax Exp ::= doExecOrEval(Object, Object, Object, String)
  rule doExecOrEval(Expression, Globals, Locals, S:String) =>
  test(Locals is not None, test(hasmember(Locals, "keys", false), .K, raiseInternal("TypeError", "locals must be a mapping")), .K) ~>
  test(Globals is not None, test(istype(Globals, ref("dict")), .K, raiseInternal("TypeError", "globals must be a dict")), .K) ~>
  test(Globals is None, test(Locals is None, parseAndExecOrEval(Expression, ref("globals")(.Arguments), ref("locals")(.Arguments), S), parseAndExecOrEval(Expression, ref("globals")(.Arguments), Locals, S)), test(Locals is None, parseAndExecOrEval(Expression, Globals, Globals, S), parseAndExecOrEval(Expression, Globals, Locals, S)))
  syntax Exp ::= parseAndExecOrEval(Exp, Exp, Exp, String) [strict(1, 2, 3)]
  rule <k> parseAndExecOrEval(Expression, Globals, Locals:Object, S:String) =>
  try: Globals["__builtins__"] ; except ref("KeyError") : Globals["__builtins__"] = ref(N) . f_builtins ~>
  test(istype(Expression, ref("code")), if ref("len")(Expression . co_freevars) > 0: raiseInternal("TypeError", "code object passed to " +String S +String "() may not contain free variables") else: #if S ==String "eval" #then eval(Expression, Globals, Locals, getEvalArgs(Expression)) #else eval(Expression, Globals, Locals, getEvalArgs(Expression)) ; ~> ref("None") #fi, ref(S)(ref("compile")(Expression, "<string>", S), Globals, Locals)) ...</k>
  <frameObject> N </frameObject>
  syntax Exp ::= eval(Exp, Exp, Exp, Exp) [strict]
  rule <k> eval(CO, Globals, Locals:Object, map(M:Map)) ~> K:K => executeFrame(N, CO, ref(Frame), Locals, Globals, Globals["__builtins__"], makeCells(tuple(.Exps), CO . co_cellvars, tuple(.Exps), N), M) ~> return </k>
       <nextLoc> N => N +Int 1 </nextLoc>
	   <control>...
	     <currentFrame>
		   <frameObject> Frame:Int => N </frameObject>
		   <fstack> FL => . </fstack>
		   <xcontext> XC </xcontext>
		   (C => <xstack> .List </xstack> <lstack> .List </lstack>)
		 </currentFrame>
		 <cstack> . => ListItem(call(Frame, C, FL, XC, K)) ...</cstack>
	   ...</control>

  syntax Exp ::= getEvalArgs(Object)
  rule getEvalArgs(CO) => test(getattr(CO, "co_argcount") >Int 0, raiseInternal("TypeError", "cannot eval code objects with positional arguments"), .K) ~> test(getattr(CO, "co_kwonlyargcount") >Int 0, raiseInternal("TypeError", "cannot eval code objects with keyword-only arguments"), .K) ~> test(getattr(CO, "co_flags") &Int 4 ==Int 0, test(getattr(CO, "co_flags") &Int 8 ==Int 0, map(.), getEvalKwArg(CO, {.KeyData})), test(getattr(CO, "co_flags") &Int 8 ==Int 0, getEvalVarArg(CO, tuple(.Exps)), getEvalKwAndVarArg(CO, tuple(.Exps), {.KeyData})))
  syntax Exp ::= getEvalKwArg(Exp, Exp) [strict] 
               | getEvalVarArg(Exp, Exp) [strict]
               | getEvalKwAndVarArg(Exp, Exp, Exp) [strict]
  rule <k> getEvalKwArg(obj(Code,_), EmptyDict:Object) => map(String2Id(S:String) |-> ref(id(EmptyDict))) ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(VarNames) "co_argcount" |-> ArgCount "co_kwonlyargcount" |-> KwOnlyArgCount ...</oattrs>
       ...</object>
       <object>...
         <id> VarNames </id>
         <oattrs>... "__value__" |-> list(L:List ListItem(ref(N)) _) ...</oattrs>
       ...</object>
       <object>...
         <id> N </id>
         <oattrs>... "__value__" |-> S ...</oattrs>
       ...</object> when lengthList L ==Int ArgCount +Int KwOnlyArgCount
  rule <k> getEvalVarArg(obj(Code,_), EmptyTuple:Object) => map(String2Id(S:String) |-> ref(id(EmptyTuple))) ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(VarNames) "co_argcount" |-> ArgCount "co_kwonlyargcount" |-> KwOnlyArgCount ...</oattrs>
       ...</object>
       <object>...
         <id> VarNames </id>
         <oattrs>... "__value__" |-> list(L:List ListItem(ref(N)) _) ...</oattrs>
       ...</object>
       <object>...
         <id> N </id>
         <oattrs>... "__value__" |-> S ...</oattrs>
       ...</object> when lengthList L ==Int ArgCount +Int KwOnlyArgCount
  rule <k> getEvalKwAndVarArg(obj(Code,_), EmptyTuple:Object, EmptyDict:Object) => map(String2Id(S:String) |-> ref(id(EmptyTuple)) String2Id(S2:String) |-> ref(id(EmptyDict))) ...</k>
       <object>...
         <id> Code </id>
         <oattrs>... "co_varnames" |-> ref(VarNames) "co_argcount" |-> ArgCount "co_kwonlyargcount" |-> KwOnlyArgCount ...</oattrs>
       ...</object>
       <object>...
         <id> VarNames </id>
         <oattrs>... "__value__" |-> list(L:List ListItem(ref(N)) ListItem(ref(N2)) _) ...</oattrs>
       ...</object>
       <object>...
         <id> N </id>
         <oattrs>... "__value__" |-> S ...</oattrs>
       ...</object>
       <object>...
         <id> N2 </id>
         <oattrs>... "__value__" |-> S2 ...</oattrs>
       ...</object> when lengthList L ==Int ArgCount +Int KwOnlyArgCount





endmodule
