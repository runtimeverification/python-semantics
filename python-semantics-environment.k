require "python-semantics-common.k"

module PYTHON-SEMANTICS-ENVIRONMENT
  imports PYTHON-SEMANTICS-COMMON

  syntax ObjRef ::= "envLookup" "(" String "," Exp "," Exp ")" [strict(2, 3)]
  syntax K ::= doBind2(String, Exp, Exp, Exp) [strict(3, 4)]

  rule unbind(X) => bind(X, ref(0)) [macro]
  rule <k> bind(X:Id, B:Exp) => doBind(Id2String(X), B, ref(N)) ...</k>
       <frameObject> N </frameObject>

  rule <k> X:Id => envLookup(Id2String(X),ref(N),ref(N) . String2Id("f_code")) ...</k>
       <frameObject> N:Int </frameObject>

  syntax #Id ::= "f_locals" | "f_globals"

  rule envLookup(S:String, Frame:Object, Code:Object) =>
            (getref(Frame, "f_locals") [S]
        if
            S in getref(Frame, "f_locals")
        else 
            raiseInternal("UnboundLocalError", "local variable '" +String S +String "' referenced before assignment"))
    if
        S in getref(Code, "co_varnames") or
        S in getref(Code, "co_cellvars")
    else 
            test(getattr2(getref(Frame, "f_cells")[S], "cell_contents") ==Obj .Obj,
                 raiseInternal("NameError", "free variable '" +String S +String "' referenced before assignment in enclosing scope"),
                 getref2(getref(Frame, "f_cells")[S], "cell_contents"))
        if 
            S in getref(Code, "co_freevars")
        else
            (try:
                getref(Frame, "f_locals") [S]
            except ref("KeyError"):
                (try:
                    getref(Frame, "f_globals") [S]
                except ref("KeyError"):
                    (try:
                        getref(Frame, "f_builtins") [S]
                    except ref("KeyError"):
                        raiseInternal("NameError", "name '" +String S +String "' is not defined"))))::K

  rule doBind(S, B, Frame) => doBind2(S, B, Frame, getref2(Frame, "f_code"))
  rule doBind2(S, B, Frame, Code:Object) =>
            test(getattr(Code, "co_type"),
                (if S in getref(Code, "co_nonlocals") :
                    STOREDEREF(S, B, Frame, Code)
                else:
                    if S in getref(Code, "co_globals") :
                        STOREGLOBAL(S, B, Frame, Code)
                    else:
                        STORENAME(S, B, Frame, Code)),
                if S in getref(Code, "co_names") :
                    STOREGLOBAL(S, B, Frame, Code)
                else:
                    STOREDEREF(S, B, Frame, Code))

  syntax K ::= STOREDEREF(String, K, Exp) [strict(3)]
  rule STOREDEREF(S, ref(B), Frame:Object) => STOREDEREF(S, ref(B), Frame, getref2(Frame, "f_code"))

  rule STOREDEREF(S:String, ref(B:ObjId), Frame:Object, Code:Object) =>
                                        if S in getref(Code, "co_varnames") or
                                           S in getref(Code, "co_cellvars") or
                                           S in getref(Code, "co_freevars") :
                                              test(getattr(Code, "co_type"),
                                                    .K,
                                                    test(B ==K 0,
                                                        (if S in getref(Frame, "f_locals") : del getref(Frame, "f_locals") [S] else: raiseInternal("UnboundLocalError", "local variable '" +String S +String "' referenced before assignment")),
                                                        getref(Frame, "f_locals") [S] = ref(B)))
                                         else: pass ~>
                                         if S in getref(Code, "co_cellvars") or 
                                            S in getref(Code, "co_freevars") :
                                              test(B ==K 0,
                                                   setattr(id(getref(Frame, "f_cells")[S]), "cell_contents", .Obj),
                                                   setref(id(getref(Frame, "f_cells")[S]), "cell_contents", ref(B)))
                                         else: pass ~>
                                         if S in getref(Code, "co_freevars") :
                                              STOREDEREF(S, ref(B), getref2(getref(Frame, "f_cells")[S], "cell_frame"))
                                         else: pass
  rule STOREGLOBAL(S:String, ref(B:ObjId), Frame:Object, Code:Object) =>
                                              test(B ==K 0,
                                                   (if S in getref(Frame, "f_globals") : del ((getref(Frame, "f_globals") [S])) else: raiseInternal("NameError", "name '" +String S +String "' is not defined")),
                                                   (getref(Frame, "f_globals") [S] = ref(B)))
  rule STORENAME(S:String, ref(B:ObjId), Frame:Object, Code:Object) =>
                                              test(B ==K 0,
                                                   (if S in getref(Frame, "f_locals") : del getref(Frame, "f_locals") [S] else: raiseInternal("NameError", "name '" +String S +String "' is not defined")),
                                                   getref(Frame, "f_locals") [S] = ref(B))
                                        

  rule [globals]: <k> invokeBuiltin(obj("globals",_), ., .) => ref(N) . f_globals ...</k>
       <frameObject> N </frameObject>
 
  rule <k> invokeBuiltin(obj("locals",_), ., .) => ref(N) . f_locals ...</k>
       <frameObject> N </frameObject>
   
endmodule
