require "python-semantics-literals.k"

module PYTHON-SEMANTICS-SLICING
  imports PYTHON-SEMANTICS-LITERALS

  syntax Expression ::= "slice" "(" Expression "," Expression ")" [strict]
                  | "slice2" "(" Expression "," Expression "," Expression ")" [strict]
                  | "slicepart" "(" Expression ")" [strict] 
                  | "indices" "(" Expression "," Expression "," Expression "," Expression ")" [strict]
                  | "indices2" "(" Expression "," Expression "," Int "," Int ")" [strict(1 2)]
                  | "indices3" "(" Int "," Int "," Int "," Int ")"
                  | "indices4" "(" Int "," Int "," Int "," Int ")"
                  | "indices5" "(" Int "," Int "," Int ")"
                  | "index" "(" Expression ")" [strict]
                  | "iters" "(" List ")"
                  | "makeMap" "(" Expression "," Expression "," List ")" [strict(1 2)]
                  | "range" "(" Expression "," Expression "," Expression "," Expression ")" [strict]

  syntax Arguments ::= "nexts" "(" List ")" [function]

  rule slice(O:Object, Slice:Object) => slice2(O, Slice, Slice . String2Id("indices") ( ref("len") (O)))
  rule slice2(O, Slice, Indices:Object) => ref("map")(O . String2Id("__getitem__"), ref("range")(* Indices), .Arguments)

  rule invokeBuiltin(obj("new_map",_), ListItem(O) ListItem(O2) L:List, .) => newHelper(O, ref("map"), .) ~> iters(L) ~> list(.) ~> makeMap(O, O2, .)

  rule (. => ref("iter") (O, .Arguments)) ~>  iters((ListItem(O) => .) L)
  rule (O:Object => .) ~> iters(_) ~> list(_ (. => ListItem(O)))
  rule iters(.) => .
  rule (list(L) => .) ~> makeMap(_, O, (. => L))
  rule makeMap(O, O2, L) => mutable("__func__" |-> id(O2) "__iters__" |-> list(Idify(L)), O)

  rule invokeBuiltin(obj("map_next",_), ListItem(O), .) => getref(O, "__func__")(nexts(getl(getattr(O, "__iters__"))))

  rule nexts(ListItem(B:Builtin) L:List) => ((ref(B) . String2Id("__next__")) (.Arguments)) , nexts(L) [function, anywhere]
  rule nexts(.) => .Arguments [function, anywhere]

  rule invokeBuiltin(obj("new_range",_), ListItem(O) ListItem(O2), .) => newHelper(O, ref("range"), .) ~> ref("new_range") (O, 0, O2, .Arguments)

  rule invokeBuiltin(obj("new_range",_), ListItem(O) ListItem(O2) ListItem(O3), .) => newHelper(O, ref("range"), .) ~> ref("new_range") (O, O2, O3, 1, .Arguments)

  rule invokeBuiltin(obj("new_range",_), ListItem(O) ListItem(O2) ListItem(O3) ListItem(O4), .) => newHelper(O, ref("range"), .) ~> range(index(O2), index(O3), index(O4), O)

  rule invokeBuiltin(obj("iter_range",_), ListItem(O), .) => mutable("current" |-> getattr(O, "start") "stop" |-> getattr(O, "stop") "step" |-> getattr(O, "step"), ref("iterator"))

  rule <k> invokeBuiltin(obj("iter_next",_), ListItem(obj(B:Builtin,_)), .) => test(test(Step <Int 0, Current >Int Stop, Current <Int Stop), Current, raise ref("StopIteration")) ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "current" |-> (Current:Int => Current +Int Step) "stop" |-> Stop "step" |-> Step ...</oattrs>
       ...</object>

  rule index(O) => getmember(O, "__index__", true, false, false) (.Arguments)
  rule range(O, O2, O3, O4) => mutable("start" |-> intvalue(O) "stop" |-> intvalue(O2) "step" |-> intvalue(O3), O4) when intvalue(O3) =/=Int 0

  rule range(_, _, O3, _) => raiseInternal("ValueError", "range() arg 3 must not be zero") when intvalue(O3) ==Int 0

  rule invokeBuiltin(obj("new_slice",_), ListItem(O:Object) ListItem(O2:Object), .) => newHelper(O, ref("slice"), .) ~> ref("new_slice") (O, ref("None"), O2, .Expressions)

  rule invokeBuiltin(obj("new_slice",_), ListItem(O:Object) ListItem(O2:Object) ListItem(O3:Object), .) => newHelper(O, ref("slice"), .) ~> ref("new_slice") (O, O2, O3, ref("None"), .Expressions)

 rule invokeBuiltin(obj("new_slice",_), ListItem(O) ListItem(O2) ListItem(O3) ListItem(O4:Object), .) => newHelper(O, ref("slice"), .) ~> mutable("start" |-> id(O2) "stop" |-> id(O3) "step" |-> id(O4), O)

  rule invokeBuiltin(obj("indices_slice",_), ListItem(O) ListItem(O2), .) => indices(slicepart(getref(O, "start")), slicepart(getref(O, "stop")), slicepart(getref(O, "step")), index(O2) -> raiseInternal("TypeError","object cannot be interpreted as an integer"))

  rule slicepart(O) => test(plbool(O is ref("None")), O, index(O) -> raiseInternal("TypeError", "slice indices must be integers or None or have an __index__ method"))

  rule indices(StartObj:Object, StopObj:Object, StepObj:Object, LengthObj:Object) => raiseInternal("ValueError", "slice step cannot be zero") when intvalue(StepObj) ==Int 0

  rule <k> indices(StartObj, StopObj, StepObj, LengthObj) => indices2(StartObj, StopObj, #if id(StepObj) ==K None #then 1 #else intvalue(StepObj) #fi, intvalue(LengthObj)) ...</k>
       <symbols>... "None" |-> None:Nat ...</symbols> when id(StepObj) ==K None orElseBool intvalue(StepObj) =/=Int 0

  rule <k> indices2(StartObj, StopObj, Step:Int, Length:Int) => indices3(#if id(StartObj) ==K None #then #if Step <Int 0 #then Length -Int 1 #else 0 #fi #else intvalue(StartObj) #fi, #if id(StopObj) ==K None #then #if Step <Int 0 #then -1 #else Length #fi #else intvalue(StopObj) #fi, Step, Length) ...</k>
       <symbols>... "None" |-> None:Nat ...</symbols>

  rule indices3(Start:Int, Stop:Int, Step, Length) => indices4(#if Start <Int 0 #then #if Start +Int Length <Int 0 #then #if Step <Int 0 #then -1 #else 0 #fi #else Start +Int Length #fi #else Start #fi, #if Stop <Int 0 #then #if Stop +Int Length <Int 0 #then #if Step <Int 0 #then -1 #else 0 #fi #else Stop +Int Length #fi #else Stop #fi, Step, Length)

  rule indices4(Start, Stop, Step, Length) => indices5(#if Start >=Int Length #then #if Step <Int 0 #then Length -Int 1 #else Length #fi #else Start #fi, #if Stop >=Int Length #then #if Step <Int 0 #then Length -Int 1 #else Length #fi #else Stop #fi, Step)

  rule indices5(Start, Stop, Step) => tuple(Start, Stop, Step, .Expressions)

endmodule
