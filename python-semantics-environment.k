require "python-semantics-common.k"

module PYTHON-SEMANTICS-ENVIRONMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "envLookup" "(" String "," Expression "," Expression ")" [strict(2, 3)]
  syntax K ::= "doBind" "(" String "," Builtin "," Expression ")" [strict(3)]
  syntax K ::= "doBind2" "(" String "," Builtin "," Expression "," Expression ")" [strict(3, 4)]

  rule unbind(X) => bind(X, 0) [macro, anywhere]
  rule <k> bind(X:Id, B:Builtin) => doBind(Id2String(X), B, ref(N)) ...</k>
       <currentFrame> N </currentFrame>

  rule <k> X:Id => envLookup(Id2String(X),ref(N),ref(N) . String2Id("f_code")) ...</k>
       <currentFrame> N:Int </currentFrame>

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

  rule doBind(S, B, Frame) => doBind2(S, B, Frame, Frame . String2Id("f_code"))
  rule doBind2(S:String, B:Builtin, Frame:Object, Code:Object) => if S in Code . String2Id("co_varnames") or
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
                                              doBind(S, B, getref2(getref(Frame, "f_cells")[S], "cell_frame"))
                                         else: pass ~>
                                         if S in Code . String2Id("co_names") :
                                              test(B ==K 0,
                                                   (del ((Frame . String2Id("f_globals") [S]), .Expressions)),
                                                   (((Frame . String2Id("f_globals") [S]), .Expressions) := ref(B)))
                                         else: pass

  rule <k> invokeBuiltin(obj("call_globals",_), ., .) => ref(N) . String2Id("f_globals") ...</k>
       <currentFrame> N </currentFrame>
 
  rule <k> invokeBuiltin(obj("call_locals",_), ., .) => ref(N) . String2Id("f_locals") ...</k>
       <currentFrame> N </currentFrame>
   
endmodule
