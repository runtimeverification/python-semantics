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

  syntax #Id ::= "f_locals" | "f_globals"

  rule envLookup(S:String, Frame:Object, Code:Object) =>
                (Frame . f_locals [S]
           if
                S in Frame . f_locals
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
                   Frame . f_globals [S]
               if
                   S in Frame . f_globals
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
                                                   (if S in Frame . f_locals : del Frame . f_locals [S] else: raiseInternal("UnboundLocalError", "local variable '" +String S +String "' referenced before assignment")),
                                                   Frame . f_locals [S] = ref(B))
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
                                                   (if S in Frame . f_globals : del ((Frame . f_globals [S])) else: raiseInternal("NameError", "name '" +String S +String "' is not defined")),
                                                   (Frame . f_globals [S] = ref(B)))
                                         else: pass

  rule [globals]: <k> invokeBuiltin(obj("globals",_), ., .) => ref(N) . f_globals ...</k>
       <frameObject> N </frameObject>
 
  rule <k> invokeBuiltin(obj("locals",_), ., .) => ref(N) . f_locals ...</k>
       <frameObject> N </frameObject>
   
endmodule
