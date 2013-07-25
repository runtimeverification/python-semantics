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
      <k> (. => garbageCollect(refcount(C <k> K </k> <store> C2 </store>))) ~> K </k>
      <nextLoc> N </nextLoc>
      <gc> N2 => N </gc>
      <store> C2:Bag </store>
      <gcThreshold> N3 </gcThreshold>
    </T> when N2 <Int N andBool N -Int N2 >Int N3 [structural]

  rule <k> garbageCollect(B:Bag) => garbageCollect(everything(C:Bag) -Set DeBagify(B), B, .) ...</k>
       <store> C:Bag </store>
  rule <k> (. => clearWeakrefs(#if "__weakrefs__" in keys Attrs #then Attrs("__weakrefs__") #else list(.) #fi)) ~> garbageCollect((SetItem(N) => .) S, B:Bag, Garbage:Bag (. => refcountbag(<object> C:Bag <id>N</id><oattrs>Attrs:Map </oattrs> </object>))) ...</k>
       (<object> C:Bag <id>N</id> <oattrs> Attrs:Map </oattrs> </object> => .)
       <literals> L => clearLiteral(L, N) </literals>
  rule [garbage-collection-cascade]: garbageCollect(., B, Garbage) => garbageCollect(DeBagify(B) -Set DeBagify(B -Bag Garbage), B -Bag Garbage, .) when Garbage =/=Bag .
  rule garbageCollect(., _, .) => .

  syntax K ::= garbageCollect(Bag)
             | garbageCollect(Set, Bag, Bag)

  syntax Map ::= clearLiteral(Map, Int)
  rule clearLiteral(_ |-> ref(N) L, N) => L
  rule clearLiteral(L, N) => L when notBool ref(N) in values(L)
 
  syntax Set ::= everything(StoreCellFragment) [function]
  syntax Bag ::= refcount(TCellFragment) [function]
               | refcountbag(Bag) [function]
               | refcountk(K) [function]
               | refcountlistk(KList) [function]
               | refcountklabel(KLabel) [function]
               | refcountmap(Map) [function]
               | refcountset(Set) [function]
               | refcountlist(List) [function]

  rule everything(<object>...<id>B</id>...</object> C:Bag) => SetItem(B) everything(C)
  rule everything(.Bag) => .Set

  syntax Bag ::= Bagify(Set) [function]
  rule Bagify(SetItem(K) S) => BagItem(K) Bagify(S)
  rule Bagify(.) => .
  syntax Set ::= DeBagify(Bag) [function]
  rule DeBagify(BagItem(K) B) => SetItem(K) DeBagify(B)
  rule DeBagify(.) => .
  syntax Bag ::= Bag "-Bag" Bag [function]
  rule (BagItem(K) B1:Bag) -Bag (BagItem(K) B2:Bag) => B1 -Bag B2
  rule (BagItem(K) B1:Bag) -Bag B2:Bag => BagItem(K) (B1 -Bag B2) when notBool BagItem(K) in B2
  rule .Bag -Bag _:Bag => .Bag
  syntax Bool ::= BagItem "in" Bag [function]
                | K "#inBag" Bag
  rule BagItem(K) in B:Bag => K #inBag B ==K true 
  rule K #inBag BagItem(K) _:Bag => true
  syntax Bag ::= Bag "intersectBag" Bag [function]
  rule A intersectBag B => B -Bag (B -Bag A)
  syntax Bool ::= Bag "=/=Bag" Bag [function]
  rule B1 =/=Bag B2 => Bag2KLabel B1(.KList) =/=K Bag2KLabel B2(.KList)

  //ideally we would treat a ref(S:String) to an object with an integer ID as a reference to that object. But we can't do that easily. Fortunately, objects in the global symbol table should never die, so we just keep them alive artificially.
  rule [refcount]: refcount(<k> K </k> <control> C <currentFrame> C2 </currentFrame> </control> <store> C3 </store> <symbols> Symbols </symbols> _:Bag) => Bagify(keys Symbols values Symbols) refcountk(K) refcountbag(C C2 C3)
  rule refcountbag(BI:BagItem BI2:BagItem C) => refcountbag(BI) refcountbag(BI2) refcountbag(C)
  rule refcountbag(.) => .

  rule refcountbag(<xstack> L:List </xstack>) => refcountlist(L)
  rule refcountbag(<lstack> L:List </lstack>) => refcountlist(L)
  rule refcountbag(<fstack> L:List </fstack>) => refcountlist(L)
  rule refcountbag(<cstack> L:List </cstack>) => refcountlist(L)
  rule refcountbag(<scope> L:List </scope>) => refcountlist(L)
  rule refcountbag(<xcontext> K </xcontext>) => refcountk(K)
  rule refcountbag(<frameObject> Frame </frameObject>) => BagItem(Frame)

  rule refcountbag(<object>... <oenv> Env:Map </oenv> <oattrs> Attrs:Map </oattrs> ...</object>) => refcountset(values Env) refcountset(values Attrs)
  rule refcountbag(<object> <id> _ </id> <oattrs> Attrs:Map </oattrs> </object>) => refcountset(values Attrs)

  rule refcountk(Lbl:KLabel(Kl:KList) ~> Lbl2:KLabel(Kl2:KList) ~> K2) => refcountk(Lbl(Kl)) refcountk(Lbl2(Kl2)) refcountk(K2)
  rule refcountk(Lbl:KLabel(Kl:KList)) => refcountklabel(Lbl) refcountlistk(Kl) when Lbl =/=KLabel 'obj andThenBool Lbl =/=KLabel 'ref`(_`)
  rule refcountk(.) => .
  rule refcountk(HOLE) => .

  rule refcountk(obj(N,_)) => BagItem(N)
  rule refcountk(ref(N)) => BagItem(N)

  rule refcountlistk(K,,Kl:KList) => refcountk(K) refcountlistk(Kl)
  rule refcountlistk(.KList) => .

  rule refcountklabel(Map2KLabel M:Map) => refcountmap(M)
  rule refcountklabel(Set2KLabel S:Set) => refcountset(S)
  rule refcountklabel(List2KLabel L:List) => refcountlist(L)
  rule refcountklabel(Bag2KLabel B:Bag) => refcountbag(B)
  rule refcountklabel(KList2KLabel Kl:KList) => refcountlistk(Kl)
  rule refcountklabel(KLabel2KLabel Lbl:KLabel) => refcountklabel(Lbl)
  rule refcountklabel(#freezer K) => refcountk(K)
  rule refcountklabel(Lbl:KLabel) => . when is#String(Lbl(.KList))
  rule refcountklabel(Lbl:KLabel) => . when is#Bool(Lbl(.KList))
  rule refcountklabel(Lbl:KLabel) => . when is#Int(Lbl(.KList))
  rule refcountklabel(Lbl:KLabel) => . when is#Float(Lbl(.KList))
  rule refcountklabel(Lbl:KLabel) => . when is#Id(Lbl(.KList))
  rule refcountklabel(Lbl:KLabel) => . when is#String(KLabel2String(Lbl))

  rule refcountmap(K |-> K2 M:Map) => refcountk(K ~> K2) refcountmap(M)
  rule refcountmap(.) => .

  rule refcountlist(ListItem(K) L:List) => refcountk(K) refcountlist(L)
  rule refcountlist(.) => .

  rule refcountset(SetItem(K) S:Set) => refcountk(K) refcountset(S)
  rule refcountset(.) => .

  rule invokeBuiltin(obj("weakref.__new__",_), ListItem(Cls:Object) ListItem(O:Object) ListItem(Callback:Object), .) => newHelper(Cls, ref("weakref"), .) ~> makeWeakref(O, mutable("referent" |-> id(O) "callback" |-> ref(id(Callback)), ref("weakref")))
  rule invokeBuiltin(obj("weakref.__new__",_), ListItem(Cls:Object) ListItem(O:Object), .) => newHelper(Cls, ref("weakref"), .) ~> makeWeakref(O, mutable("referent" |-> id(O) "callback" |-> .Obj, ref("weakref")))
  syntax ObjRef ::= makeWeakref(Exp, Exp) [strict]
  rule makeWeakref(O:Object, Weakref:Object) => setattr(id(O), "__weakrefs__", list(getl(#if hasattr(O, "__weakrefs__") #then getattr(O, "__weakrefs__") #else list(.) #fi) ListItem(ref(id(Weakref))))) ~> Weakref

  rule <k> invokeBuiltin(obj("weakref.__call__",_), ListItem(O:Object), .) => #if getattr(O, "referent") =/=K .Obj #then ref(getattr(O, "referent")) #else ref("None") #fi ...</k>
       <store> C:Bag </store>

  syntax K ::= clearWeakrefs(K)
  rule clearWeakrefs(list(ListItem(ref(N)) L:List)) => setattr(N, "referent", .Obj) ~> try: test(getref2(ref(N), "callback") ==Obj .Obj, pass, getref2(ref(N), "callback") (ref(N)) ;) except ref("BaseException") : ref("print")("Exception " + ref("sys_exc_info")(.Arguments)[1] + " ignored") ; else: pass ~> clearWeakrefs(list(L))
  rule clearWeakrefs(list(.)) => . 

  // since garbage collection is implementation specific, we treat the number of objects collected by any given call to the garbage collector as a symbolic int
  rule <k> invokeBuiltin(obj("gc.collect",_), ., .) => ?Num:Int ...</k>
       <gcThreshold> N </gcThreshold>
       <gc> _ => 0 -Int N </gc>

endmodule
