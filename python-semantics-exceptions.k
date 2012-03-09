module PYTHON-SEMANTICS-EXCEPTIONS
  imports PYTHON-SEMANTICS-COMMON

  rule <k> invokeBuiltin(obj("init_baseexception",_), ListItem(obj(B:Builtin,_)) L:List, .) => ref("None") ...</k>
       <object>...
         <id>B</id>
         <oattrs> OAttrs:Map => OAttrs[list(Idify(L)) / "args"] </oattrs>
       ...</object>

end module
