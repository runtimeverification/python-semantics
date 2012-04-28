module PYTHON-SEMANTICS-ENVIRONMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "envLookup" "(" #Id "," Expression "," Expression ")" [:strict(2 3):]
  syntax K ::= "doBind" "(" #Id "," Builtin "," Expression ")" [:strict(3):]
  syntax K ::= "doBind2" "(" #Id "," Builtin "," Expression "," Expression ")" [:strict(3 4):]

  macro unbind(X) = bind(X, 0)
  rule <k> bind(X:#Id, B:Builtin) => doBind(X, B, ref(N)) ...</k>
       <currentFrame> N </currentFrame>

  rule <k> X => envLookup(X,ref(N),ref(N) . #id "f_code") ...</k>
       <currentFrame> N:#Nat </currentFrame>

  rule envLookup(#id S:#String, Frame:Object, Code:Object) =>
       (Frame . #id "f_locals" [S]
       if
            S in Frame . #id "f_locals"
       else 
            raiseInternal("NameError", "free variable '" +String S +String "' referenced before assignment in enclosing scope")
            if
                 S in Code . #id "co_cellvars" or
                 S in Code . #id "co_freevars"
            else 
                 raiseInternal("UnboundLocalError", "local variable '" +String S +String "' referenced before assignment"))
       if
            S in Code . #id "co_varnames" or
            S in Code . #id "co_cellvars" or
            S in Code . #id "co_freevars"
       else
            Frame . #id "f_globals" [S]
            if
                 S in Frame . #id "f_globals"
            else
                 Frame . #id "f_builtins" [S]
                 if
                      S in Frame . #id "f_builtins"
                 else
                      raiseInternal("NameError", "name '" +String S +String "' is not defined")

  rule doBind(X, B, Frame) => doBind2(X, B, Frame, Frame . #id "f_code")
  rule doBind2(#id S, B, Frame, Code) => if S in Code . #id "co_varnames" or
                                            S in Code . #id "co_cellvars" or
                                            S in Code . #id "co_freevars" :
                                              test(B ==Bool 0,
                                                   del Frame . #id "f_locals" [S],
                                                   ((Frame . #id "f_locals" [S]), .Expressions) := ref(B))
                                         else: pass ~>
                                         if S in Code . #id "co_cellvars" or 
                                            S in Code . #id "co_freevars" :
                                              test(B ==Bool 0,
                                                   setattr(getref(Frame, "f_cells")[S], "cell_contents", .Obj),
                                                   setattr(getref(Frame, "f_cells")[S], "cell_contents", B))
                                         else: pass ~>
                                         if S in Code . #id "co_freevars" :
                                              doBind(#id S, B, getref(getref(Frame, "f_cells")[S], "cell_frame"))
                                         else: pass ~>
                                         if S in Code . #id "co_names" :
                                              test(B ==Bool 0,
                                                   del Frame . #id "f_globals" [S],
                                                   ((Frame . #id "f_globals" [S]), .Expressions) := ref(B))
                                         else: pass

  rule <k> invokeBuiltin(obj("call_globals",_), ., .) => ref(N) . #id "f_globals" ...</k>
       <currentFrame> N </currentFrame>
    
end module
