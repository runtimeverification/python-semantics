require "python-semantics-literals.k"

module PYTHON-SEMANTICS-ENVIRONMENT
  imports PYTHON-SEMANTICS-LITERALS

  syntax ObjRef ::= "envLookup" "(" String "," Expression "," Expression ")" [strict(2, 3)]
  syntax K ::= "doBind2" "(" String "," Expression "," Expression "," Expression ")" [strict(3, 4)]

  rule unbind(X) => bind(X, ref(0)) [macro, anywhere]
  rule <k> bind(X:Id, B:Expression) => doBind(Id2String(X), B, ref(N)) ...</k>
       <frameObject> ref(N) </frameObject>

  rule <k> X:Id => envLookup(Id2String(X),ref(N),getref2(ref(N), "f_code")) ...</k>
       <frameObject> ref(N:Int) </frameObject>

  rule envLookup(S:String, Frame:Object, Code:Object) =>
                (Frame . String2Id("f_locals") [S]
           if
                S in Frame . String2Id("f_locals")
           else 
                raiseInternal("UnboundLocalError", "local variable '" +String S +String "' referenced before assignment"))
       if
            S in Code . String2Id("co_varnames") or
            S in Code . String2Id("co_cellvars")
       else 
               test(getattr2(getref(Frame, "f_cells")[S], "cell_contents") ==Obj .Obj,
                    raiseInternal("NameError", "free variable '" +String S +String "' referenced before assignment in enclosing scope"),
                    getref2(getref(Frame, "f_cells")[S], "cell_contents"))
           if 
               S in Code . String2Id("co_freevars")
           else
                   Frame . String2Id("f_globals") [S]
               if
                   S in Frame . String2Id("f_globals")
               else
                       Frame . String2Id("f_builtins") [S]
                   if
                       S in Frame . String2Id("f_builtins")
                   else
                       raiseInternal("NameError", "name '" +String S +String "' is not defined")
  when notBool getattr(Frame, "f_isbuiltin")

  rule envLookup(S:String, Frame:Object, Code:Object) => getm(getattr(Frame, "f_locals"))(S) when getattr(Frame, "f_isbuiltin")

  rule <k> doBind(S, B, Frame) => doBind2(S, B, Frame, Frame . String2Id("f_code")) ...</k> when notBool getattr(Frame, "f_isbuiltin")
  rule <k> doBind(S, ref(0), obj(Frame,_)) => . ...</k>
       <object>...
         <id>Frame</id>
         <oattrs>... "f_isbuiltin" |-> true "f_locals" |-> map(M => M[undef / S]) ...</oattrs>
       ...</object>
  rule <k> doBind(S, B, obj(Frame,_)) => . ...</k>
       <object>...
         <id>Frame</id>
         <oattrs>... "f_isbuiltin" |-> true "f_locals" |-> map(M => M[B / S]) ...</oattrs>
       ...</object> when B =/=K ref(0)

  rule doBind2(S:String, ref(B:ObjId), Frame:Object, Code:Object) => if S in Code . String2Id("co_varnames") or
                                            S in Code . String2Id("co_cellvars") or
                                            S in Code . String2Id("co_freevars") :
                                              test(B ==K 0,
                                                   (del Frame . String2Id("f_locals") [S], .Expressions),
                                                   Frame . String2Id("f_locals") [S], .Expressions := ref(B))
                                         else: pass ~>
                                         if S in Code . String2Id("co_cellvars") or 
                                            S in Code . String2Id("co_freevars") :
                                              test(B ==K 0,
                                                   setattr(id(getref(Frame, "f_cells")[S]), "cell_contents", .Obj),
                                                   setref(id(getref(Frame, "f_cells")[S]), "cell_contents", ref(B)))
                                         else: pass ~>
                                         if S in Code . String2Id("co_freevars") :
                                              doBind(S, ref(B), getref2(getref(Frame, "f_cells")[S], "cell_frame"))
                                         else: pass ~>
                                         if S in Code . String2Id("co_names") :
                                              test(B ==K 0,
                                                   (del ((Frame . String2Id("f_globals") [S]), .Expressions)),
                                                   (((Frame . String2Id("f_globals") [S]), .Expressions) := ref(B)))
                                         else: pass

  //rule [globals]: <k> invokeBuiltin(obj("globals",_), ., .) => ref(N) . String2Id("f_globals") ...</k>
  //     <frameObject> ref(N) </frameObject>
 
  //rule <k> invokeBuiltin(obj("locals",_), ., .) => ref(N) . String2Id("f_locals") ...</k>
  //     <frameObject> ref(N) </frameObject>
   
endmodule
