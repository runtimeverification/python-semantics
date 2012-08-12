module PYTHON-SEMANTICS-GARBAGE-COLLECTION
  imports PYTHON-SEMANTICS-COMMON

  rule <T>
         C:Bag
         <store>
           (<object>...
             <id> B:Builtin </id>
           ...</object> => .)
           C2:Bag
         </store>
       </T> when notBool(refcount(B, <T> C <store> C2 </store> </T>))

  syntax Bool ::= "refcount" "(" Builtin "," Bag ")" [:function:]
                | "refcountattrs" "(" Builtin "," Map ")" [:function:]
                | "refcountk" (" Builtin "," K ")" [:function:]

  define refcount(B, <T>... <k> K:K </k> <control> C </control> <store> C2 </store> ...</T>) => refcountk(B, K) orElseBool refcount(B, C) orElseBool refcount(B, C2)
  define refcount(B, BI:BagItem BI2:BagItem C) => refcount(B, BI) orElseBool refcount(B, BI2) orElseBool refcount(B, C)
  define refcount(_, .) => false
  define refcount(B, <xstack> (K, K2:K, C, Ex:Builtin, _) XL:List </xstack>) => refcountk(B, K) orElseBool refcountk(B, K2) orElseBool refcount(B, C) orElseBool B ==K Ex orElseBool refcount(B, <xstack> XL </xstack>)
  define refcount(B, <xstack> . </xstack>) => false
  define refcount(B, <xcontext> Ex </xcontext) => B ==K Ex
  define refcount(B, <currentFrame> Frame:Builtin </currentFrame) => B ==K Frame
  define refcount(B, <xstack> (K, C, XL, LL, FL, Ex) XL2:List </xstack) => refcountk(B, K) orElseBool refcount(B, C) orElseBool refcount(B, <xstack> XL </xstack>) orElseBool refcount(B, <lstack> LL </lstack>) orElseBool refcount(B, <fstack> FL </fstack>) orElseBool B ==K Ex orElseBool refcount(B, <xstack> XL2 </xstack>)
  define refcount(B, <lstack> (K, C, XL, LL, FL, Ex) LL2:List </xstack) => refcountk(B, K) orElseBool refcount(B, C) orElseBool refcount(B, <xstack> XL </xstack>) orElseBool refcount(B, <lstack> LL </lstack>) orElseBool refcount(B, <fstack> FL </fstack>) orElseBool B ==K Ex orElseBool refcount(B, <lstack> LL2 </lstack>)
  define refcount(B, <fstack> (K, C, XL, LL, FL, Ex) FL2:List </xstack) => refcountk(B, K) orElseBool refcount(B, C) orElseBool refcount(B, <xstack> XL </xstack>) orElseBool refcount(B, <lstack> LL </lstack>) orElseBool refcount(B, <fstack> FL </fstack>) orElseBool B ==K Ex orElseBool refcount(B, <fstack> FL2 </fstack>)
  define refcount(B, <lstack> (K, K2, C) LL:List </lstack>) => refcountk(B, K) orElseBool refcountk(B, K2) orElseBool refcount(B, C) orElseBool refcount(B, <lstack> LL </lstack>)
  define refcount(B, <lstack> . </lstack>) => false
  define refcount(B, <fstack> (K, C, Frame, LL) FL:List </fstack) => refcountk(B, K) orElseBool refcount(B, C) orElseBool B ==K Frame orElseBool refcount(B, <lstack> LL </lstack>) orElseBool refcount(B, <fstack> FL </fstack)
  define refcount(B, <fstack> . </fstack) => false
  define refcount(B, <scope> (CO:Builtin, _:Set, _:Set, _:Set, _:Set, _:Set) SL:List </scope>) => B ==K CO orElseBool refcount(B, <scope> SL </scope>)
  define refcount(B, <scope> . </scope) => false

  define refcount(B, <object>... <oenv> Env:Map </oenv> <oattrs> Attrs:Map </oattrs> ...</object>) => B in values Env orElseBool refcountattrs(B, Attrs)
  define refcountattrs(B, S |-> K M:Map) => refcountk(B, K) orElseBool refcountattrs(B, M)

  define refcountk(B, K ~> K2) => refcountk(B, K) orElseBool refcountk(B, K2)
  define refcountk(B, Lbl:KLabel(K,,Kl:List{K})) => refcountk(K) orElseBool refcountk(Lbl(Kl)) when Lbl =/=KLabel 'obj`(_`,_`) andBool Lbl =/=KLabel 'ref`(_`)
  define refcountk(B, obj(B,_)) => true
  define refcountk(B, ref(B)) => true
  define refcountk(B, obj(B2,_)) => false when B =/=K B2
  define refcountk(B, ref(B2)) => false when B =/=K B2
  define refcountk(B, Lbl(.List{K})) => false

end module
