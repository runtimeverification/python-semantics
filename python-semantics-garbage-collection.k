module PYTHON-SEMANTICS-GARBAGE-COLLECTION
  imports PYTHON-SEMANTICS-COMMON

  rule [run-garbage-collection]:
    <T>
      C:Bag
      <nextLoc> N </nextLoc>
      <garbage> .Set => everything(C2) -Set refcount(C <store> C2 </store>) </garbage>
      <gc> N2 => N </gc>
      <store> C2:Bag </store>
      <gcThreshold> N3 </gcThreshold>
    </T> when N2 <Int N andBool N -Int N2 >Int N3 [structural]

  rule [collect-garbage]:
    (<object>... <id>N</id> ...</object> => .)
    <garbage>... SetItem(N) => . ...</garbage>
    <literals> L </literals> when notBool(ref(N) in values(L))

  rule [collect-garbage-interned]:
    (<object>... <id>N</id> ...</object> => .)
    <garbage>... SetItem(N) => . ...</garbage>
    <literals>... _ |-> ref(N) => . ...</literals>

  syntax Set ::= refcount(Bag) [function]
                | refcountbag(Bag) [function]
                | refcountk(K) [function]
                | refcountlistk(List{K}) [function]
                | refcountklabel(KLabel) [function]
                | refcountmap(Map) [function]
                | refcountset(Set) [function]
                | refcountlist(List) [function]
                | everything(Bag) [function]

  rule everything(<object>...<id>B</id>...</object> C:Bag) => SetItem(B) everything(C)
  rule everything(.Bag) => .Set

  rule [refcount]: refcount(<k> K </k> <control> C </control> <store> C2 </store> <symbols> Symbols </symbols> _:Bag) => (values Symbols) refcountk(K) refcountbag(C) refcountbag(C2)
  rule refcountbag(BI:BagItem BI2:BagItem C) => refcountbag(BI) refcountbag(BI2) refcountbag(C)

  rule refcountbag(<xstack> (K, K2, C, K3, _) XL:List </xstack>) => refcountk(K ~> K2 ~> K3) refcountbag(C <xstack> XL </xstack>)

  rule refcountbag(<xcontext> K </xcontext>) => refcountk(K)

  rule refcountbag(<currentFrame> Frame </currentFrame>) => SetItem(Frame)

  rule refcountbag(<xstack> (K, C, XL, LL, FL, K2) XL2:List </xstack>) => refcountk(K ~> K2) refcountbag(C <xstack> XL XL2 </xstack> <lstack> LL </lstack> <fstack> FL </fstack>)
  rule refcountbag(<lstack> (K, C, XL, LL, FL, K2) LL2:List </lstack>) => refcountk(K ~> K2) refcountbag(C <xstack> XL </xstack> <lstack> LL LL2 </lstack> <fstack> FL </fstack>)
  rule refcountbag(<fstack> (K, C, XL, LL, FL, K2) FL2:List </fstack>) => refcountk(K ~> K2) refcountbag(C <xstack> XL </xstack> <lstack> LL </lstack> <fstack> FL FL2 </fstack>)

  rule refcountbag(<lstack> (K, K2, C) LL:List </lstack>) => refcountk(K ~> K2) refcountbag(C <lstack> LL </lstack>)

  rule refcountbag(<fstack> (K, C, Frame, LL) FL:List </fstack>) => refcountk(K ~> ref(Frame)) refcountbag(C <lstack> LL </lstack> <fstack> FL </fstack>)

  rule refcountbag(<scope> (CO, _:Set, _:Set, _:Set, _:Set, _:Set, _:List, _) SL:List </scope>) => refcountk(ref(CO)) refcountbag(<scope> SL </scope>)

  rule refcountbag(<object>... <oenv> Env:Map </oenv> <oattrs> Attrs:Map </oattrs> ...</object>) => refcountset(values Env) refcountset(values Attrs)
  rule refcountbag(<object>... <oattrs> Attrs:Map </oattrs> ...</object>) => refcountset(values Attrs)

  rule refcountk(Lbl:KLabel(Kl:List{K}) ~> Lbl2:KLabel(Kl2:List{K}) ~> K2) => refcountk(Lbl(Kl)) refcountk(Lbl2(Kl2)) refcountk(K2)
  rule refcountk(Lbl:KLabel(Kl:List{K})) => refcountklabel(Lbl) refcountlistk(Kl) when Lbl =/=KLabel 'obj`(_`,_`) andThenBool Lbl =/=KLabel 'ref`(_`)

  rule refcountk(obj(N,_)) => SetItem(N)
  rule refcountk(ref(N)) => SetItem(N)

  rule refcountlistk(K,,Kl:List{K}) => refcountk(K) refcountlistk(Kl)

  rule refcountklabel(Map2KLabel M:Map) => refcountmap(M)
  rule refcountklabel(Set2KLabel S:Set) => refcountset(S)
  rule refcountklabel(List2KLabel L:List) => refcountlist(L)
  rule refcountklabel(List{K}2KLabel Kl:List{K}) => refcountlistk(Kl)

  rule refcountmap(K |-> K2 M:Map) => refcountk(K ~> K2) refcountmap(M)

  rule refcountlist(ListItem(K) L:List) => refcountk(K) refcountlist(L)

  rule refcountset(SetItem(K) S:Set) => refcountk(K) refcountset(S)

endmodule
