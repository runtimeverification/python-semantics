require "python-semantics-common.k"

module PYTHON-SEMANTICS-ENVIRONMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "envLookup" "(" String "," Exp "," Exp ")" [strict(2, 3)]
  syntax K ::= "doBind2" "(" String "," Exp "," Exp "," Exp ")" [strict(3, 4)]

  rule unbind(X) => bind(X, ref(0)) [macro]
  rule <k> bind(X:Id, B:Exp) => doBind(Id2String(X), B, ref(N)) ...</k>
       <frameObject> N </frameObject>

  rule <k> X:Id => envLookup(Id2String(X),ref(N),ref(N) . String2Id("f_code")) ...</k>
       <frameObject> N:Int </frameObject>

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
  rule doBind2(S:String, ref(B:ObjId), Frame:Object, Code:Object) => if S in Code . String2Id("co_varnames") or
                                            S in Code . String2Id("co_cellvars") or
                                            S in Code . String2Id("co_freevars") :
                                              test(B ==K 0,
                                                   (del Frame . String2Id("f_locals") [S]),
                                                   Frame . String2Id("f_locals") [S] = ref(B))
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
                                                   (del ((Frame . String2Id("f_globals") [S]))),
                                                   (((Frame . String2Id("f_globals") [S])) = ref(B)))
                                         else: pass

  rule [globals]: <k> invokeBuiltin(obj("globals",_), ., .) => ref(N) . String2Id("f_globals") ...</k>
       <frameObject> N </frameObject>
 
  rule <k> invokeBuiltin(obj("locals",_), ., .) => ref(N) . String2Id("f_locals") ...</k>
       <frameObject> N </frameObject>
   
endmodule
