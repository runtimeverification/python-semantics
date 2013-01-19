require "python-semantics-calls.k"
require "python-semantics-functions.k"
require "python-semantics-statements.k"
require "python-semantics-generator.k"

module PYTHON-SEMANTICS-GARBAGE-COLLECTION
  imports PYTHON-SEMANTICS-CALLS
  imports PYTHON-SEMANTICS-FUNCTIONS
  imports PYTHON-SEMANTICS-STATEMENTS
  imports PYTHON-SEMANTICS-GENERATOR

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
                | refcountlistk(KList) [function]
                | refcountklabel(KLabel) [function]
                | refcountmap(Map) [function]
                | refcountset(Set) [function]
                | refcountlist(List) [function]
                | everything(Bag) [function]

  rule everything(<object>...<id>B</id>...</object> C:Bag) => SetItem(B) everything(C)
  rule everything(.Bag) => .Set

  rule [refcount]: refcount(<k> K </k> <control> C <currentFrame> C2 </currentFrame> </control> <store> C3 </store> <symbols> Symbols </symbols> _:Bag) => (values Symbols) refcountk(K) refcountbag(C C2 C3)
  rule refcountbag(BI:BagItem BI2:BagItem C) => refcountbag(BI) refcountbag(BI2) refcountbag(C)

  rule refcountbag(<xstack> try(K, K2, C, K3, _) XL:List </xstack>) => refcountk(K ~> K2 ~> K3) refcountbag(C <xstack> XL </xstack>)

  rule refcountbag(<xcontext> K </xcontext>) => refcountk(K)

  rule refcountbag(<frameObject> Frame </frameObject>) => SetItem(Frame)

  rule refcountbag(<xstack> finally(K, C, XL, LL, FL, K2) XL2:List </xstack>) => refcountk(K ~> K2) refcountbag(C <xstack> XL XL2 </xstack> <lstack> LL </lstack> <fstack> FL </fstack>)
  rule refcountbag(<lstack> finally(K, C, XL, LL, FL, K2) LL2:List </lstack>) => refcountk(K ~> K2) refcountbag(C <xstack> XL </xstack> <lstack> LL LL2 </lstack> <fstack> FL </fstack>)
  rule refcountbag(<fstack> finally(K, C, XL, LL, FL, K2) FL2:List </fstack>) => refcountk(K ~> K2) refcountbag(C <xstack> XL </xstack> <lstack> LL </lstack> <fstack> FL FL2 </fstack>)

  rule refcountbag(<lstack> loop(K, K2, C) LL:List </lstack>) => refcountk(K ~> K2) refcountbag(C <lstack> LL </lstack>)

  rule refcountbag(<cstack> call(K, C, FL, XC, K2) CL:List </cstack>) => refcountk(K ~> XC ~> K2) refcountbag(C <fstack> FL </fstack> <cstack> CL </cstack>)
  rule refcountbag(<cstack> generator(K, C, FL, XC, K2, N) CL:List </cstack>) => refcountk(K ~> XC ~> K2) refcountbag(C <fstack> FL </fstack> <cstack> CL </cstack>) SetItem(N)

  rule refcountbag(<scope> scope(CO, _:Set, _:Set, _:Set, _:Set, _:Set, _:List, _, _) SL:List </scope>) => refcountk(ref(CO)) refcountbag(<scope> SL </scope>)

  rule refcountbag(<object>... <oenv> Env:Map </oenv> <oattrs> Attrs:Map </oattrs> ...</object>) => refcountset(values Env) refcountset(values Attrs)
  rule refcountbag(<object>... <oattrs> Attrs:Map </oattrs> ...</object>) => refcountset(values Attrs)

  rule refcountk(Lbl:KLabel(Kl:KList) ~> Lbl2:KLabel(Kl2:KList) ~> K2) => refcountk(Lbl(Kl)) refcountk(Lbl2(Kl2)) refcountk(K2)
  rule refcountk(Lbl:KLabel(Kl:KList)) => refcountklabel(Lbl) refcountlistk(Kl) when Lbl =/=KLabel 'obj`(_`,_`) andThenBool Lbl =/=KLabel 'ref`(_`)

  rule refcountk(obj(N,_)) => SetItem(N)
  rule refcountk(ref(N)) => SetItem(N)

  rule refcountlistk(K,,Kl:KList) => refcountk(K) refcountlistk(Kl)

  rule refcountklabel(Map2KLabel M:Map) => refcountmap(M)
  rule refcountklabel(Set2KLabel S:Set) => refcountset(S)
  rule refcountklabel(List2KLabel L:List) => refcountlist(L)
  rule refcountklabel(KList2KLabel Kl:KList) => refcountlistk(Kl)
  rule refcountklabel(#freezer K) => refcountk(K)

  rule refcountmap(K |-> K2 M:Map) => refcountk(K ~> K2) refcountmap(M)

  rule refcountlist(ListItem(K) L:List) => refcountk(K) refcountlist(L)

  rule refcountset(SetItem(K) S:Set) => refcountk(K) refcountset(S)

endmodule
