require "python-semantics-builtin-modules.k"

module PYTHON-SEMANTICS-DUNDER-BUILTIN
  imports PYTHON-SEMANTICS-BUILTIN-MODULES

  rule <k> builtins => (

         // module "builtins"
         object "AssertionError"("type",ListItem("Exception"),.,.) ~>
         object "AttributeError"("type",ListItem("Exception"),.,.) ~>
         object "BaseException"("type",ListItem("object"),
           "__cause__" |-> ref("__cause__")
           "__context__" |-> ref("__context__")
           "__init__" |-> def "init_baseexception" (0, -1, true)
           ,.) ~>
         object "__cause__" ("reference",.,., "__get__" |-> "__cause__") ~>
         object "__context__" ("reference",.,., "__get__" |-> "__context__") ~>
         object "Exception"("type",ListItem("BaseException"),.,.) ~>
         object "False"("bool",.,.,
           "__value__" |-> 0) ~>
         object "IndexError"("type",ListItem("LookupError"),.,.) ~>
         object "KeyError"("type",ListItem("LookupError"),.,.) ~>
         object "LookupError"("type",ListItem("Exception"),.,.) ~>
         object "NameError"("type",ListItem("Exception"),.,.) ~>
         object "None"("NoneType",.,.,.) ~>
         object "NoneType"("type",ListItem("object"),.,.) ~>
         object "NotImplemented"("NotImplementedType",.,.,.) ~>
         object "NotImplementedType"("type",ListItem("object"),.,.) ~>
         object "RuntimeError"("type",ListItem("Exception"),.,.) ~>
         object "StopIteration"("type",ListItem("Exception"),.,.) ~>
         object "SyntaxError"("type",ListItem("Exception"),.,.) ~>
         object "True"("bool",.,.,
           "__value__" |-> 1) ~>
         object "TypeError"("type",ListItem("Exception"),.,.) ~>
         object "UnboundLocalError"("type",ListItem("NameError"),.,.) ~>
         object "ValueError"("type",ListItem("Exception"),.,.) ~>
         object "bool"("type",ListItem("int"),
           "__new__" |-> def "new_bool" (1, 2, false)
           ,.) ~>
         object "classmethod"("type", ListItem("object"),
           "__get__" |-> def "get_classmethod"(1, 2, true)
           "__init__" |-> def "init_classmethod"(1, 1, true)
           "__new__" |-> def "new_classmethod"(2, 2, false)
           ,.) ~>
         object "complex"("type",ListItem("object"),.,.) ~>
         object "dict"("type",ListItem("object"),
           "keys" |-> def "keys_dict" (0, 0, true)
           "__delitem__" |-> def "delitem_dict" (1, 1, true)
           "__getitem__" |-> def "getitem_dict" (1, 1, true)
           "__init__" |-> def "init_dict" (0, 1, true)
           "__iter__" |-> def "iter_dict" (0, 0, true)
           "__len__" |-> def "len_dict" (0, 0, true)
           "__new__" |-> def "new_dict" (1, -1, false)
           "__setitem__" |-> def "setitem_dict" (2, 2, true)
           ,.) ~>
         object "dict_keys" ("type",ListItem("object"),
           "__iter__" |-> def "iter_dict_keys" (0, 0, true)
           ,.) ~>
         object "getattr" ( "builtin-function" ,.,.,
           "__call__" |-> def "call_getattr" (2, 3, false)
           ) ~>
         object "globals" ( "builtin-function" ,.,.,
           "__call__" |-> def "call_globals" (0, 0, false)
           ) ~>
         object "hash"( "builtin-function" ,.,.,
           "__call__" |-> def "call_hash" (1, 1, false)
           ) ~>
         object "int"("type",ListItem("object"),
           "__abs__" |-> def "abs_int" (0, 0, true)
           "__add__" |-> def "add_int" (1, 1, true)
           "__and__" |-> def "and_int" (1, 1, true)
           "__bool__" |-> def "bool_int" (0, 0, true)
           "__ceil__" |-> def "ceil_int" (0, 0, true)
           //TODO: divmod, doc
           "__eq__" |-> def "eq_int"(1, 1, true)
           //TODO: float
           "__floor__" |-> def "floor_int" (0, 0, true)
           "__floordiv__" |-> def "floordiv_int" (1, 1, true)
           //TODO: format
           "__ge__" |-> def "ge_int" (1, 1, true)
           //TODO: getattribute, getnewargs
           "__gt__" |-> def "gt_int" (1, 1, true)
           //TODO: hash
           "__index__" |-> ref("int_int")
           "__int__" |-> def "int_int" (0, 0, true)
           "__invert__" |-> def "invert_int" (0, 0, true)
           "__le__" |-> def "le_int" (1, 1, true)
           "__lshift__" |-> def "lshift_int" (1, 1, true)
           "__lt__" |-> def "lt_int" (1, 1, true)
           "__mod__" |-> def "mod_int" (1, 1, true)
           "__mul__" |-> def "mul_int" (1, 1, true)
           "__ne__" |-> def "ne_int" (1, 1, true)
           "__neg__" |-> def "neg_int" (0, 0, true)
           "__new__" |-> def "new_int" (1, 3, false)
           "__or__" |-> def "or_int" (1, 1, true)
           "__pos__" |-> def "pos_int" (0, 0, true)
           "__pow__" |-> def "pow_int" (1, 2, true)
           "__radd__" |-> def "radd_int" (1, 1, true)
           "__rand__" |-> def "rand_int" (1, 1, true)
           //TODO: rdivmod, repr
           "__rfloordiv__" |-> def "rfloordiv_int" (1, 1, true)
           "__rlshift__" |-> def "rlshift_int" (1, 1, true)
           "__rmod__" |-> def "rmod_int" (1, 1, true)
           "__rmul__" |-> def "rmul_int" (1, 1, true)
           "__ror__" |-> def "ror_int" (1, 1, true)
           //TODO: round
           "__rpow__" |-> def "rpow_int" (1, 1, true)
           "__rrshift__" |-> def "rrshift_int" (1, 1, true)
           "__rshift__" |-> def "rshift_int" (1, 1, true)
           "__rsub__" |-> def "rsub_int" (1, 1, true)
           "__rtruediv__" |-> def "rtruediv_int" (1, 1, true)
           "__rxor__" |-> def "rxor_int" (1, 1, true)
           //TODO: sizeof, str
           "__sub__" |-> def "sub_int" (1, 1, true)
           "__truediv__" |-> def "truediv_int" (1, 1, true)
           "__trunc__" |-> def "trunc_int" (0, 0, true)
           "__xor__" |-> def "xor_int" (1, 1, true)
           //TODO: bit_length, conjugate, denominator, from_bytes, imag,
           //        numerator, real, to_bytes
           ,.) ~>
         object "iter"( "builtin-function" ,.,.,
           "__call__" |-> def "call_iter" (1, 2, false)
           ) ~>
         object "iterator"("type",ListItem("object"),
           "__iter__" |-> def "iter_iter" (0, 0, true)
           "__next__" |-> def "iter_next" (0, 0, true)
           ,.) ~> 
         object "float"("type",ListItem("object"),.,.) ~>
         object "len"( "builtin-function" ,.,.,
           "__call__" |-> def "call_len" (1, 1, false)
           ) ~>
         object "list"("type",ListItem("object"),
           "__eq__" |-> def "eq_list" (1, 1,  true)
           "__init__" |-> def "init_list" (0, 1, true)
           "__iter__" |-> def "get_iter" (0, 0, true)
           "__getitem__" |-> def "getitem_list" (1, 1, true)
           "__len__" |-> def "len_list" (0, 0, true)
           "__ne__" |-> def "ne_list" (1, 1, true)
           "__new__" |-> def "new_list" (1, -1, false)
           ,.) ~>
         object "map"("type",ListItem("object"),
           "__iter__" |-> ref("iter_iter")
           "__new__" |-> def "new_map" (3, -1, false)
           "__next__" |-> def "map_next" (0, 0, true)
           ,.) ~>
         object "module"("type",ListItem("object"),
           "__dict__" |-> ref("__dict__")
           ,.) ~>
         object "__dict__"("reference",.,., "__get__" |-> "__dict__") ~>
         object "object"("type",.,
           "__class__" |-> ref("__class__")
           "__getattribute__" |-> def "getattribute_object" (1, 1, true)
           "__eq__" |-> def "eq_object" (1, 1, true)
           "__init__" |-> def "init_object" (0, -1, true)
           "__ne__" |-> def "ne_object" (1, 1, true)
           "__new__" |-> def "new_object" (1, -1, false)
           "__setattr__" |-> def "setattr_object"(2, 2, true)
           ,.) ~>
         object "__class__" ("reference",.,., "__get__" |-> "__class__") ~>
         object "range" ("type",ListItem("object"),
           "__iter__" |-> def "iter_range" (0, 0, true)
           "__new__" |-> def "new_range" (1, 4, false)
           ,.) ~>
         object "setattr" ( "builtin-function" ,.,.,
           "__call__" |-> def "call_setattr" (3, 3, false)
           ) ~>
         object "slice" ("type",ListItem("object"),
           "indices" |-> def "indices_slice" (1, 1, true)
           "start" |-> ref("start")
           "stop" |-> ref("stop")
           "step" |-> ref("step")
           "__new__" |-> def "new_slice" (1, 4, false)
           ,.) ~>
         object "start"("attribute",.,., "__get__" |-> "start") ~>
         object "stop"("attribute",.,., "__get__" |-> "stop") ~>
         object "step"("attribute",.,., "__get__" |-> "step") ~>
         object "str"("type",ListItem("object"),
           "__add__" |-> def "add_str" (1, 1, true)
           "__eq__" |-> def "eq_str" (1, 1, true)
           "__hash__" |-> def "hash_str" (0, 0, true)
           "__ne__" |-> def "ne_str" (1, 1, true)
           ,.) ~>
         object "tuple"("type",ListItem("object"),
           "__add__" |-> def "add_tuple" (1, 1, true)
           "__contains__" |-> def "contains_tuple" (1, 1, true)
           "__getitem__" |-> def "getitem_tuple" (1, 1, true)
           "__iter__" |-> ref("get_iter")
           "__len__" |-> def "len_tuple" (0, 0, true)
           "__new__" |-> def "new_tuple" (1, 2, false)
           ,.) ~>
         object "type"("type",ListItem("object"),
           "__bases__" |-> ref("__bases__")
           "__call__" |-> def "call_type" (0, -1, true)
           "__getattribute__" |-> def "getattribute_type" (1, 1, true)
           "__mro__" |-> ref("__mro__")
           "__name__" |-> ref("__name__type")
           "__new__" |-> def "new_type"(2, 4, false)
           "__prepare__" |-> def "prepare_type"(0, -1, false)
           "__setattr__" |-> def "setattr_type"(2, 2, true)
           "mro" |-> def "mro_type"(0, 0, true)
           ,.) ~>
         object "__name__type" ("attribute",.,., "__get__" |-> "__name__") ~>
         object "__bases__" ("reference",.,., "__get__" |-> "__bases__") ~>
         object "__mro__" ("reference",.,., "__get__" |-> "__mro__") ~>
         // module "types"
         object "attribute"("type",ListItem("object"),
           "__get__" |-> def "get_attr" (1, 2, true)
           "__set__" |-> def "set_attr" (2, 2, true)
           , "__name__" |-> undefined("internal type name")) ~>
         object "builtin-function" ("type",ListItem("object"),
           "__call__" |-> def "call_builtin_function" (0, -1, true)
           , "__name__" |-> undefined("internal type name")) ~>
         object "builtin-method" ("type",ListItem("object"),
           "__call__" |-> ref("call_builtin_function")
           "__get__" |-> def "get_builtin_method" (1, 2, true)
           , "__name__" |-> undefined("internal type name")) ~>
         object "code"("type",ListItem("object"),
           "co_name" |-> ref("co_name")
           "co_argcount" |-> ref("co_argcount")
           "co_nlocals" |-> ref("co_nlocals")
           "co_varnames" |-> ref("co_varnames")
           "co_cellvars" |-> ref("co_cellvars")
           "co_freevars" |-> ref("co_freevars")
           "co_consts" |-> ref("co_consts")
           "co_names" |-> ref("co_names")
           ,.) ~>
         object "co_name" ("attribute",.,., "__get__" |-> "co_name") ~>
         object "co_argcount" ("attribute",.,., "__get__" |-> "co_argcount") ~>
         object "co_nlocals" ("attribute",.,., "__get__" |-> "co_nlocals") ~>
         object "co_varnames" ("reference",.,., "__get__" |-> "co_varnames") ~>
         object "co_cellvars" ("reference",.,., "__get__" |-> "co_cellvars") ~>
         object "co_freevars" ("reference",.,., "__get__" |-> "co_freevars") ~>
         object "co_consts" ("reference",.,., "__get__" |-> "co_consts") ~>
         object "co_names" ("reference",.,., "__get__" |-> "co_names") ~>
         object "frame"("type",ListItem("object"),
           "f_back" |-> ref("f_back")
           "f_builtins" |-> ref("f_builtins")
           "f_code" |-> ref("f_code")
           "f_globals" |-> ref("f_globals")
           "f_lasti" |-> ref("f_lasti")
           "f_locals" |-> ref("f_locals")
           , "f_lasti" |-> undefined("bytecode is implementation specific")) ~>
         object "f_back" ("reference",.,., "__get__" |-> "f_back") ~>
         object "f_builtins" ("reference",.,., "__get__" |-> "f_builtins") ~>
         object "f_code" ("reference",.,., "__get__" |-> "f_code") ~>
         object "f_globals" ("reference",.,., "__get__" |-> "f_globals") ~>
         object "f_locals" ("reference",.,., "__get__" |-> "f_locals") ~>
         object "function"("type",ListItem("object"),
           "__annotations__" |-> ref("__annotations__")
           "__call__" |-> def "call_function" (0, -1, true)
           "__closure__" |-> ref("__closure__")
           "__code__" |-> ref("__code__")
           "__defaults__" |-> ref("__defaults__")
           "__doc__" |-> ref("__doc__")
           "__get__" |-> def "get_function" (1, 2, true)
           "__globals__" |-> ref("__globals__")
           "__kwdefaults__" |-> ref("__kwdefaults__")
           "__module__" |-> ref("__module__") 
           "__name__" |-> ref("__name__function")
           ,.) ~>
         object "__annotations__" ("reference",.,., "__get__" |-> "__annotations__") ~>
         object "__closure__" ("reference",.,., "__get__" |-> "__closure__") ~>
         object "__code__" ("reference",.,., "__get__" |-> "__code__") ~>
         object "__defaults__" ("reference",.,., "__get__" |-> "__defaults__") ~>
         object "__doc__" ("reference",.,., "__get__" |-> "__doc__") ~>
         object "__globals__" ("reference",.,., "__get__" |-> "__globals__") ~>
         object "__kwdefaults__" ("reference",.,., "__get__" |-> "__kwdefaults__") ~>
         object "__module__" ("reference",.,., "__get__" |-> "__module__" "__set__" |-> def "set_ref_default"(3, 3, false)) ~>
         object "__name__function"("reference",.,., "__get__" |-> "__name__" "__set__" |-> def "set_attr_string"(3, 3, false)) ~>
         object "method" ("type", ListItem("object"),
           "__call__" |-> def "call_method" (0, -1, true)
           "__func__" |-> ref("__func__")
           "__self__" |-> ref("__self__")
           , .) ~>
         object "__func__" ("reference",.,., "__get__" |-> "__func__") ~>
         object "__self__" ("reference",.,., "__get__" |-> "__self__") ~>
         object "reference"("type",ListItem("object"),
           "__get__" |-> def "get_ref" (1, 2, true)
           "__set__" |-> def "set_ref" (2, 2, true)
           , "__name__" |-> undefined("internal type name")) ~>

         // misc builtins
         object "cell"("type",ListItem("object"),
           ., .) ~>
         object "cell_contents" ("reference",.,., "__get__" |-> "cell_contents")) ...</k>

  rule <k> modules => (

         // module declarations
         module "_io"({.KeyData}) ~>
         module "_os"({.KeyData}) ~>
         module "_warnings"({.KeyData}) ~>
         module "builtins"({
           "AssertionError" : ref("AssertionError")
         , "AttributeError" : ref("AttributeError")
         , "BaseException" : ref("BaseException")
         , "Exception" : ref("Exception")
         , "False" : ref("False")
         , "IndexError" : ref("IndexError")
         , "KeyError" : ref("KeyError")
         , "LookupError" : ref("LookupError")
         , "NameError" : ref("NameError")
         , "None" : ref("None")
         , "NotImplemented" : ref("NotImplemented")
         , "RuntimeError" : ref("RuntimeError")
         , "StopIteration" : ref("StopIteration")
         , "SyntaxError" : ref("SyntaxError")
         , "True" : ref("True")
         , "TypeError" : ref("TypeError")
         , "UnboundLocalError" : ref("UnboundLocalError")
         , "ValueError" : ref("ValueError")
         , "__debug__" : #if T #then ref("True") #else ref("False") #fi
         , "__doc__" : "Built-in functions, exceptions, and other objects.\n\nNoteworthy: None is the `nil' object; Ellipsis represents `...' in slices."
         , "bool" : ref("bool")
         , "classmethod" : ref("classmethod")
         , "complex" : ref("complex")
         , "dict" : ref("dict")
         , "hash" : ref("hash")
         , "int" : ref("int")
         , "iter" : ref("iter")
         , "float" : ref("float")
         , "getattr" : ref("getattr")
         , "len" : ref("len")
         , "list" : ref("list")
         , "map" : ref("map")
         , "object" : ref("object")
         , "range" : ref("range")
         , "setattr" : ref("setattr")
         , "slice" : ref("slice")
         , "str" : ref("str")
         , "tuple" : ref("tuple")
         , "type" : ref("type")
         , .KeyData
         }) ~>
         module "errno"({.KeyData}) ~>
         module "imp"({.KeyData}) ~>
         module "marshal"({.KeyData}) ~>
         module "sys"({
           "hash_info" : tuple(N1, N2, N3, N4, N5, .Expressions)
         , .KeyData
         }) ~>
         module "types"({
           "BuiltinFunctionType" : ref("builtin-function")
         , "BuiltinMethodType" : ref("builtin-method")
         , "CodeType" : ref("code")
         , "FrameType" : ref("frame")
         , "FunctionType" : ref("function")
         , "GetSetDescriptorType" : undefined("cpython implementation type")
         , "LambdaType" : ref("function")
         , "MemberDescriptorType" : undefined("cpython implementation type")
         , "MethodType" : ref("method")
         , "ModuleType" : ref("module")
         , .KeyData
         })
       ) ...</k>
       <debug> T:Bool </debug>
       <hashInfo> ListItem(N1:Int) ListItem(N2:Int) ListItem(N3:Int) ListItem(N4:Int) ListItem(N5:Int) </hashInfo>

endmodule
