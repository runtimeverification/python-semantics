require "python-semantics-builtin-modules.k"

module PYTHON-SEMANTICS-DUNDER-BUILTIN
  imports PYTHON-SEMANTICS-BUILTIN-MODULES

  rule <k> builtins => (

         // module "builtins"
         object "ArithmeticError"("type",ListItem("Exception"),.,.) ~>
         object "AssertionError"("type",ListItem("Exception"),.,.) ~>
         object "AttributeError"("type",ListItem("Exception"),.,.) ~>
         object "BaseException"("type",ListItem("object"),
           "args" |-> ref("args")
           "__cause__" |-> ref("__cause__")
           "__context__" |-> ref("__context__")
           "__new__" |-> def "BaseException.__new__" (1, -1, false)
           "__suppress_context__" |-> ref("__suppress_context__")
           "__traceback__" |-> ref("__traceback__")
           ,.) ~>
         object "args" ("attribute",.,., "__get__" |-> "args") ~>
         object "__cause__" ("attribute",.,., "__get__" |-> "__cause__") ~>
         object "__context__" ("attribute",.,., "__get__" |-> "__context__") ~>
         object "__suppress_context__" ("attribute",.,., "__get__" |-> "__suppress_context__") ~>
         object "__traceback__" ("attribute",.,., "__get__" |-> "__traceback__") ~>
         object "EOFError"("type",ListItem("Exception"),.,.) ~>
         object "Exception"("type",ListItem("BaseException"),.,.) ~>
         object "False"("bool",.,.,
           "__value__" |-> 0) ~>
         object "FileExistsError"("type",ListItem("OSError"),.,.) ~>
         object "FileNotFoundError"("type",ListItem("OSError"),.,.) ~>
         object "GeneratorExit"("type",ListItem("BaseException"),.,.) ~>
         object "ImportError"("type",ListItem("Exception"),
           "name" |-> ref("name")
           "path" |-> ref("path")
           "__init__" |-> def "ImportError.__init__"(0, -1, true)
           ,.) ~>
	 object "name"("attribute",.,.,"__get__" |-> "name") ~>
         object "path"("attribute",.,.,"__get__" |-> "path") ~>
         object "ImportWarning"("type",ListItem("Warning"),.,.) ~>
         object "IndexError"("type",ListItem("LookupError"),.,.) ~>
         object "KeyError"("type",ListItem("LookupError"),.,.) ~>
         object "LookupError"("type",ListItem("Exception"),.,.) ~>
         object "NameError"("type",ListItem("Exception"),.,.) ~>
         object "None"("NoneType",.,.,.) ~>
         object "NoneType"("type",ListItem("object"),.,.) ~>
         object "NotADirectoryError"("type",ListItem("OSError"),.,.) ~>
         object "NotImplemented"("NotImplementedType",.,.,.) ~>
         object "NotImplementedType"("type",ListItem("object"),.,.) ~>
         object "NotImplementedError"("type",ListItem("RuntimeError"),.,.) ~>
         object "OSError"("type",ListItem("Exception"),
           "errno" |-> ref("OSError.errno")
           ,.) ~>
         object "OSError.errno"("attribute",.,.,"__get__" |-> ref("args")[0]) ~>
         object "PermissionError"("type",ListItem("OSError"),.,.) ~>
         object "RuntimeError"("type",ListItem("Exception"),.,.) ~>
         object "StopIteration"("type",ListItem("Exception"),.,.) ~>
         object "SyntaxError"("type",ListItem("Exception"),.,.) ~>
         object "SystemError"("type",ListItem("Exception"),.,.) ~>
         object "True"("bool",.,.,
           "__value__" |-> 1) ~>
         object "TypeError"("type",ListItem("Exception"),.,.) ~>
         object "UnboundLocalError"("type",ListItem("NameError"),.,.) ~>
         object "UnicodeError"("type",ListItem("ValueError"),.,.) ~>
         object "UnicodeDecodeError"("type",ListItem("UnicodeError"),.,.) ~>
         object "ValueError"("type",ListItem("Exception"),.,.) ~>
         object "Warning"("type",ListItem("Exception"),.,.) ~>
         object "ZeroDivisionError"("type", ListItem("ArithmeticError"),.,.) ~>
         (def "all"(1, 1, false) ;) ~>
         object "bool"("type",ListItem("int"),
           "__new__" |-> def "new_bool" (1, 2, false)
           ,.) ~>
         object "bytes"("type",ListItem("object"),
           "__add__" |-> def "add_bytes"(1, 1, true)
           "__eq__" |-> def "eq_bytes"(1, 1, true)
           "__ge__" |-> def "ge_bytes" (1, 1, true)
           "__gt__" |-> def "gt_bytes" (1, 1, true)
           "__le__" |-> def "le_bytes" (1, 1, true)
           "__lt__" |-> def "lt_bytes" (1, 1, true)
           "__mul__" |-> def "mul_bytes" (1, 1, true)
           "__ne__" |-> def "ne_bytes" (1, 1, true)
           "__new__" |-> def "new_bytes" (0, 3, true)
           "__radd__" |-> def "radd_bytes"(1, 1, true)
           "__rmul__" |-> def "rmul_bytes" (1, 1, true)
           ,.) ~>
         object "classmethod"("type", ListItem("object"),
           "__get__" |-> def "get_classmethod"(1, 2, true)
           "__init__" |-> def "init_classmethod"(1, 1, true)
           "__new__" |-> def "new_classmethod"(2, 2, false)
           ,.) ~>
         (def "compile"(3, 6, false) ;) ~>
         object "complex"("type",ListItem("object"),.,.) ~>
         object "dict"("type",ListItem("object"),
           "get" |-> def "get_dict" (1, 2, true)
           "keys" |-> def "keys_dict" (0, 0, true)
           "update" |-> ref("init_dict")
           "__contains__" |-> def "contains_dict" (1, 1, true)
           "__delitem__" |-> def "delitem_dict" (1, 1, true)
           "__eq__" |-> def "eq_dict" (1, 1, true)
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
         object "float"("type",ListItem("object"),
           "__eq__" |-> def "float.__eq__"(1, 1, true)
           "__ge__" |-> def "float.__ge__" (1, 1, true)
           "__gt__" |-> def "float.__gt__" (1, 1, true)
           "__int__" |-> def "float.__int__" (0, 0, true)
           "__le__" |-> def "float.__le__" (1, 1, true)
           "__lt__" |-> def "float.__lt__" (1, 1, true)
           "__ne__" |-> def "float.__ne__" (1, 1, true)
           ,.) ~>
         (def "format" (1, 2, false) ;) ~>
         (def "getattr" (2, 3, false) ;) ~>
         (def "globals" (0, 0, false) ;) ~>
	 (def "hasattr" (2, 2, false) ;) ~>
         (def "hash" (1, 1, false) ;) ~>
         (def "id"(1, 1, false) ;) ~>
         (def "index" (1, 1, false) ;) ~>
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
           "__hash__" |-> def "hash_int" (0, 0, true)
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
         (def "isinstance" (2, 2, false) ;) ~>
         (def "issubclass" (2, 2, false) ;) ~>
         (def "iter" (1, 2, false) ;) ~>
         object "iterator"("type",ListItem("object"),
           "__iter__" |-> def "iter_iter" (0, 0, true)
           "__next__" |-> def "iter_next" (0, 0, true)
           ,.) ~> 
         (def "len" (1, 1, false) ;) ~>
         object "list"("type",ListItem("object"),
           "append" |-> def "append_list"(1, 1, true)
           "extend" |-> def "extend_list"(1, 1, true)
           "__add__" |-> def "add_list" (1, 1, true)
           "__eq__" |-> def "eq_list" (1, 1,  true)
           "__init__" |-> def "init_list" (0, 1, true)
           "__iter__" |-> def "get_iter" (0, 0, true)
           "__getitem__" |-> def "getitem_list" (1, 1, true)
           "__len__" |-> def "len_list" (0, 0, true)
           "__ne__" |-> def "ne_list" (1, 1, true)
           "__new__" |-> def "new_list" (1, -1, false)
           ,.) ~>
         (def "locals" (0, 0, false) ;) ~>
         object "map"("type",ListItem("object"),
           "__iter__" |-> ref("iter_iter")
           "__new__" |-> def "new_map" (3, -1, false)
           "__next__" |-> def "map_next" (0, 0, true)
           ,.) ~>
         object "module"("type",ListItem("object"),
           "__dict__" |-> ref("__dict__module")
           ,.) ~>
         object "__dict__module"("attribute",.,., "__get__" |-> "__dict__") ~>
         object "object"("type",.,
           "__class__" |-> ref("__class__")
           "__getattribute__" |-> def "getattribute_object" (1, 1, true)
           "__eq__" |-> def "eq_object" (1, 1, true)
           "__format__" |-> def "format_object" (1, 1, true)
           "__init__" |-> def "init_object" (0, -1, true)
           "__ne__" |-> def "ne_object" (1, 1, true)
           "__new__" |-> def "new_object" (1, -1, false)
           "__setattr__" |-> def "setattr_object"(2, 2, true)
           "__subclasshook__" |-> def "subclasshook_object"(0, -1, false)
           ,.) ~>
         object "__class__" ("attribute",.,., "__get__" |-> "__class__") ~>
         (def "ord" (1, 1, false) ;) ~>
         object "range" ("type",ListItem("object"),
           "__iter__" |-> def "iter_range" (0, 0, true)
           "__new__" |-> def "new_range" (1, 4, false)
           ,.) ~>
         object "reversed" ("type", ListItem("object"),
           "__new__" |-> def "reversed.__init__"(1, 1, true)
           ,.) ~>
         object "set" ("type", ListItem("object"),
           "__contains__" |-> def "contains_set" (1, 1, true)
           "__eq__" |-> def "eq_set" (1, 1, true)
           "__init__" |-> def "init_set" (0, 1, true)
           "__ior__" |-> def "ior_set"(1, 1, true)
           "__le__" |-> def "le_set"(1, 1, true)
           "__lt__" |-> def "lt_set"(1, 1, true)
           "__ne__" |-> def "ne_set"(1, 1, true)
           "__new__" |-> def "new_set" (1, -1, false)
           ,.) ~>
	 (def "setattr" (3, 3, false) ;) ~>
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
         object "staticmethod"("type", ListItem("object"),
           "__get__" |-> def "get_staticmethod"(1, 2, true)
           "__init__" |-> def "init_staticmethod"(1, 1, true)
           "__new__" |-> def "new_staticmethod"(2, 2, false)
           ,.) ~>
         object "str"("type",ListItem("object"),
           "format" |-> def "format_str"(0, -1, true)
           "join" |-> def "join_str"(1, 1, true)
           "lower" |-> def "lower_str"(0, 0, true)
           "partition" |-> def "partition_str"(1, 1, true)
           "rpartition" |-> def "rpartition_str"(1, 1, true)
           "rsplit" |-> def "rsplit_str"(0, 2, true)
           "startswith" |-> def "startswith_str"(1, 3, true)
           "__add__" |-> def "add_str" (1, 1, true)
           "__eq__" |-> def "eq_str" (1, 1, true)
           "__format__" |-> def "__format___str"(1, 1, true)
           "__getitem__" |-> def "getitem_str"(1, 1, true)
           "__hash__" |-> def "hash_str" (0, 0, true)
           "__len__" |-> def "len_str"(0, 0, true)
           "__mod__" |-> def "mod_str"(1, 1, true)
           "__mul__" |-> def "mul_str"(1, 1, true)
           "__ne__" |-> def "ne_str" (1, 1, true)
           ,.) ~>
         object "super"("type",ListItem("object"),
           "__getattribute__" |-> def "super.__getattribute__"(1, 1, true)
           "__init__" |-> def "super.__init__"(0, 2, true)
           ,.) ~>
         object "tuple"("type",ListItem("object"),
           "__add__" |-> def "add_tuple" (1, 1, true)
           "__contains__" |-> def "contains_tuple" (1, 1, true)
           "__eq__" |-> def "eq_tuple" (1, 1, true)
           "__getitem__" |-> def "getitem_tuple" (1, 1, true)
           "__hash__" |-> def "hash_tuple" (0, 0, true)
           "__iter__" |-> ref("get_iter")
           "__len__" |-> def "len_tuple" (0, 0, true)
           "__ne__" |-> def "ne_tuple" (1, 1, true)
           "__new__" |-> def "new_tuple" (1, 2, false)
           ,.) ~>
         object "type"("type",ListItem("object"),
           "mro" |-> def "mro_type"(0, 0, true)
           "__bases__" |-> ref("__bases__")
           "__call__" |-> def "call_type" (0, -1, true)
           "__getattribute__" |-> def "getattribute_type" (1, 1, true)
           "__instancecheck__" |-> def "instancecheck_type" (1, 1, true)
           "__mro__" |-> ref("__mro__")
           "__name__" |-> ref("__name__type")
           "__new__" |-> def "new_type"(2, 4, false)
           "__prepare__" |-> def "prepare_type"(0, -1, false)
           "__setattr__" |-> def "setattr_type"(2, 2, true)
           "__subclasscheck__" |-> def "subclasscheck_type"(1, 1, true)
           ,.) ~>
         object "__name__type" ("attribute",.,., "__get__" |-> "__name__") ~>
         object "__bases__" ("attribute",.,., "__get__" |-> "__bases__") ~>
         object "__mro__" ("attribute",.,., "__get__" |-> "__mro__") ~>
         // module "types"
         object "attribute"("type",ListItem("object"),
           "__get__" |-> def "get_attr" (1, 2, true)
           "__set__" |-> def "set_attr" (2, 2, true)
           , "__name__" |-> ?Name:String) ~>
         object "builtin-function" ("type",ListItem("object"),
             "__call__" |-> def "call_builtin_function" (0, -1, true)
           , "__name__" |-> ?Name2:String) ~>
         object "builtin-method" ("type",ListItem("object"),
           "__get__" |-> def "get_builtin_method" (1, 2, true)
           , "__name__" |-> ?Name3:String) ~>
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
         object "co_varnames" ("attribute",.,., "__get__" |-> "co_varnames") ~>
         object "co_cellvars" ("attribute",.,., "__get__" |-> "co_cellvars") ~>
         object "co_freevars" ("attribute",.,., "__get__" |-> "co_freevars") ~>
         object "co_consts" ("attribute",.,., "__get__" |-> "co_consts") ~>
         object "co_names" ("attribute",.,., "__get__" |-> "co_names") ~>
         object "frame"("type",ListItem("object"),
           "f_back" |-> ref("f_back")
           "f_builtins" |-> ref("f_builtins")
           "f_code" |-> ref("f_code")
           "f_globals" |-> ref("f_globals")
           "f_locals" |-> ref("f_locals")
           ,.) ~>
         object "f_back" ("attribute",.,., "__get__" |-> "f_back") ~>
         object "f_builtins" ("attribute",.,., "__get__" |-> "f_builtins") ~>
         object "f_code" ("attribute",.,., "__get__" |-> "f_code") ~>
         object "f_globals" ("attribute",.,., "__get__" |-> "f_globals") ~>
         object "f_locals" ("attribute",.,., "__get__" |-> "f_locals") ~>
         object "function"("type",ListItem("object"),
           "__annotations__" |-> ref("__annotations__")
           "__call__" |-> def "call_function" (0, -1, true)
           "__closure__" |-> ref("__closure__")
           "__code__" |-> ref("__code__")
           "__defaults__" |-> ref("__defaults__")
           "__dict__" |-> ref("__dict__function")
           "__doc__" |-> ref("__doc__")
           "__get__" |-> def "get_function" (1, 2, true)
           "__globals__" |-> ref("__globals__")
           "__kwdefaults__" |-> ref("__kwdefaults__")
           "__module__" |-> ref("__module__") 
           "__name__" |-> ref("__name__function")
           ,.) ~>
         object "__annotations__" ("attribute",.,., "__get__" |-> "__annotations__") ~>
         object "__closure__" ("attribute",.,., "__get__" |-> "__closure__") ~>
         object "__code__" ("attribute",.,., "__get__" |-> "__code__") ~>
         object "__defaults__" ("attribute",.,., "__get__" |-> "__defaults__") ~>
         object "__dict__function" ("attribute",.,., "__get__" |-> "__dict__") ~>
         object "__doc__" ("attribute",.,., "__get__" |-> "__doc__" "__set__" |-> ref("set_ref_default")) ~>
         object "__globals__" ("attribute",.,., "__get__" |-> "__globals__") ~>
         object "__kwdefaults__" ("attribute",.,., "__get__" |-> "__kwdefaults__") ~>
         object "__module__" ("attribute",.,., "__get__" |-> "__module__" "__set__" |-> def "set_ref_default"(3, 3, false)) ~>
         object "__name__function"("attribute",.,., "__get__" |-> "__name__" "__set__" |-> def "set_attr_string"(3, 3, false)) ~>
         object "generator"("type",ListItem("object"),
           "close" |-> def "close_generator"(0, 0, true)
           "send" |-> def "send_generator"(1, 1, true)
           "throw" |-> def "throw_generator"(1, 3, true)
           "__iter__" |-> def "iter_generator"(0, 0, true)
           "__next__" |-> def "next_generator"(0, 0, true)
           ,.) ~>
         object "method" ("type", ListItem("object"),
           "__call__" |-> def "call_method" (0, -1, true)
           "__func__" |-> ref("__func__")
           "__self__" |-> ref("__self__")
           , .) ~>
         object "__func__" ("attribute",.,., "__get__" |-> "__func__") ~>
         object "__self__" ("attribute",.,., "__get__" |-> "__self__") ~>
         object "traceback"("type", ListItem("object"),
           "tb_next" |-> ref("tb_next")
           "tb_frame" |-> ref("tb_frame")
           , .) ~>
         object "tb_next" ("attribute",.,., "__get__" |-> "tb_next") ~>
         object "tb_frame" ("attribute",.,., "__get__" |-> "tb_frame") ~>

         // misc builtins
         object "cell"("type",ListItem("object"),
           ., .) ~>
         object "cell_contents" ("attribute",.,., "__get__" |-> "cell_contents") ~>
         (def "new_structseq" (2, 2, false) ;) ~>

         //module "sys"
         (def "sys_exc_info" (0, 0, false) ;) ~>
         struct "sys.flags"("optimize","verbose") ~>
         struct "sys.hash_info"("width", "modulus", "inf", "nan", "imag") ~>
         struct "sys.version_info"("major", "minor", "micro", "releaselevel", "serial") ~>
         struct "sys.implementation"("name", "version", "hexversion", "cache_tag") ~>

         //module "_imp"
         (def "imp__fix_co_filename"(2, 2, false) ;) ~>
         (def "imp_acquire_lock" (0, 0, false) ;) ~>
         (def "imp_extension_suffixes" (0, 0, false) ;) ~>
         (def "imp_init_builtin" (1, 1, false) ;) ~>
         (def "imp_init_frozen" (1, 1, false) ;) ~>
         (def "imp_is_builtin" (1, 1, false) ;) ~>
         (def "imp_is_frozen" (1, 1, false) ;) ~>
         (def "imp_is_frozen_package" (1, 1, false) ;) ~>
         (def "imp_get_frozen_object" (1, 1, false) ;) ~>
         (def "imp_load_dynamic" (2, 3, false) ;) ~>
         (def "imp_release_lock" (0, 0, false) ;) ~>

         //module "_io"
         object "BytesIO"("type", ListItem("_BufferedIOBase"),
           "__init__" |-> def "BytesIO.__init__"(0, 1, true)
           "readline" |-> def "BytesIO.readline"(0, 1, true)
           ,.) ~>
         object "FileIO"("type", ListItem("_RawIOBase"),
           "__init__" |-> def "FileIO.__init__"(1, 4, true)
           "read" |-> def "FileIO.read"(0, 1, true)
           "write" |-> def "FileIO.write"(1, 1, true)
           ,.) ~>
         object "IncrementalNewlineDecoder"("type", ListItem("object"),
           "__init__" |-> def "IncrementalNewlineDecoder.__init__"(2, 3, true)
           "decode" |-> def "IncrementalNewlineDecoder.decode"(1, 2, true)
           ,.) ~>
         object "_IOBase"("type", ListItem("object"),
           "__new__" |-> def "_IOBase.__new__"(1, -1, false)
           ,.) ~>
         object "_RawIOBase"("type", ListItem("_IOBase"),
           "read" |-> def "_RawIOBase.read"(0, 1, true)
           ,.) ~>
         object "_BufferedIOBase"("type", ListItem("_IOBase"),.,.) ~>

         //module "_warnings" 
         (def "_warnings.warn" (1, 3, false) ;) ~>

         //module "_weakref"
         object "weakref"("type", ListItem("object"),
           "__call__" |-> def "weakref.__call__"(0, 0, true)
           "__new__" |-> def "weakref.__new__"(2, 3, false)
           ,.) ~>

         //module "gc"
         (def "gc.collect"(0, 0, false) ;) ~>

         //module "marshal"
         (def "marshal.dumps"(1, 2, false) ;) ~>
         (def "marshal.loads"(1, 1, false) ;) ~>

         //module "posix"
         (def "posix.getcwd"(0, 0, false) ;) ~>
         (def "posix.listdir"(0, 1, false) ;) ~>
         (def "posix.mkdir"(1, 2, false) ;) ~>
         (def "posix.open"(2, 3, false) ;) ~>
         (def "posix.replace"(2, 2, false) ;) ~>
         (def "posix.stat"(1, 1, false) ;) ~>
         (def "posix.unlink"(1, 1, false) ;) ~>
         struct "posix.stat_result" ("st_mode", "st_ino", "st_dev", "st_nlink", "st_uid", "st_gid", "st_size", "st_atime", "st_mtime", "st_ctime") ~>
         .K
       )
       ...</k>

  rule <k> modules => (

         // module declarations
         module "_imp"({
           "_fix_co_filename": ref("imp__fix_co_filename")
         , "acquire_lock" : ref("imp_acquire_lock")
         , "extension_suffixes" : ref("imp_extension_suffixes")
         , "init_builtin" : ref("imp_init_builtin")
         , "init_frozen" : ref("imp_init_frozen")
         , "is_builtin" : ref("imp_is_builtin")
         , "is_frozen" : ref("imp_is_frozen")
         , "is_frozen_package" : ref("imp_is_frozen_package")
         , "get_frozen_object" : ref("imp_get_frozen_object")
         , "load_dynamic": ref("imp_load_dynamic")
         , "release_lock" : ref("imp_release_lock")
         }) ~>
         module "_io"({
           "BytesIO" : ref("BytesIO")
         , "FileIO" : ref("FileIO")
         , "IncrementalNewlineDecoder" : ref("IncrementalNewlineDecoder")
	 }) ~>
         module "_warnings"({
           "warn" : ref("_warnings.warn")
         }) ~>
         module "_weakref"({
           "ref" : ref("weakref")
         }) ~>
         module "builtins"({
           "ArithmeticError" : ref("ArithmeticError")
         , "AssertionError" : ref("AssertionError")
         , "AttributeError" : ref("AttributeError")
         , "BaseException" : ref("BaseException")
         , "EOFError" : ref("EOFError")
         , "Exception" : ref("Exception")
         , "False" : ref("False") 
         , "FileExistsError" : ref("FileExistsError")
         , "FileNotFoundError" : ref("FileNotFoundError")
         , "GeneratorExit" : ref("GeneratorExit")
         , "IOError" : ref("OSError")
         , "ImportError" : ref("ImportError")
         , "ImportWarning" : ref("ImportWarning")
         , "IndexError" : ref("IndexError")
         , "KeyError" : ref("KeyError")
         , "LookupError" : ref("LookupError")
         , "NameError" : ref("NameError")
         , "None" : ref("None")
         , "NotADirectoryError" : ref("NotADirectoryError")
         , "NotImplemented" : ref("NotImplemented")
         , "NotImplementedError" : ref("NotImplementedError")
         , "OSError" : ref("OSError")
         , "PermissionError" : ref("PermissionError")
         , "RuntimeError" : ref("RuntimeError")
         , "StopIteration" : ref("StopIteration")
         , "SyntaxError" : ref("SyntaxError")
         , "SystemError" : ref("SystemError")
         , "True" : ref("True")
         , "TypeError" : ref("TypeError")
         , "UnboundLocalError" : ref("UnboundLocalError")
         , "UnicodeError" : ref("UnicodeError")
         , "UnicodeDecodeError" : ref("UnicodeDecodeError")
         , "ValueError" : ref("ValueError")
         , "Warning" : ref("Warning")
         , "ZeroDivisionError" : ref("ZeroDivisionError")
         , "__debug__" : #if Constants("__debug__") #then ref("True") #else ref("False") #fi
         , "__doc__" : "Built-in functions, exceptions, and other objects.\n\nNoteworthy: None is the `nil' object; Ellipsis represents `...' in slices."
         , "all" : ref("all")
         , "bool" : ref("bool")
         , "bytes" : ref("bytes")
         , "classmethod" : ref("classmethod")
         , "compile" : ref("compile")
         , "complex" : ref("complex")
         , "dict" : ref("dict")
         , "float" : ref("float")
         , "format" : ref("format")
         , "getattr" : ref("getattr")
         , "globals" : ref("globals")
         , "hasattr" : ref("hasattr")
         , "hash" : ref("hash")
         , "id" : ref("id")
         , "int" : ref("int")
         , "isinstance" : ref("isinstance")
         , "issubclass" : ref("issubclass")
         , "iter" : ref("iter")
         , "len" : ref("len")
         , "list" : ref("list")
         , "locals" : ref("locals")
         , "map" : ref("map")
         , "object" : ref("object")
         , "ord" : ref("ord")
         , "range" : ref("range")
         , "reversed" : ref("reversed")
         , "set" : ref("set")
         , "setattr" : ref("setattr")
         , "slice" : ref("slice")
         , "staticmethod" : ref("staticmethod")
         , "str" : ref("str")
         , "super" : ref("super")
         , "tuple" : ref("tuple")
         , "type" : ref("type")
         }) ~>
         module "errno"({
           "EACCES" : Constants("errno.EACCES")
         , "ELOOP" : Constants("errno.ELOOP")
         , "ENAMETOOLONG" : Constants("errno.ENAMETOOLONG")
         , "ENOENT" : Constants("errno.ENOENT")
         , "ENOTDIR" : Constants("errno.ENOTDIR")
         }) ~>
         module "gc"({
           "collect" : ref("gc.collect")
         }) ~>
         module "marshal"({
           "dumps" : ref("marshal.dumps")
         , "loads" : ref("marshal.loads")
         }) ~>
         module "posix"({
           "environ" : {DeMapify(M)}
         , "getcwd" : ref("posix.getcwd")
         , "listdir" : ref("posix.listdir")
         , "mkdir" : ref("posix.mkdir")
         , "open" : ref("posix.open")
         , "replace" : ref("posix.replace")
         , "stat" : ref("posix.stat")
         , "unlink" : ref("posix.unlink")
         , "O_WRONLY" : Constants("posix.O_WRONLY")
         , "O_CREAT": Constants("posix.O_CREAT")
         , "O_EXCL": Constants("posix.O_EXCL")
         }) ~>
         module "sys"({
           "builtin_module_names" : ["_imp", "_io", "_warnings", "_weakref", "builtins", "marshal", "posix", "sys", "types"]
         , "dont_write_bytecode" : ref("True")
         , "exc_info" : ref("sys_exc_info")
         , "flags": ref("sys.flags")(tuple(#if Constants("__debug__") #then 0 #else 1 #fi, #if Constants("PYTHONVERBOSE") #then 1 #else 0 #fi, .Exps))
         , "hash_info" : ref("sys.hash_info")(tuple(Constants("sys.hash_info.width"), Constants("sys.hash_info.modulus"), Constants("sys.hash_info.inf"), Constants("sys.hash_info.nan"), Constants("sys.hash_info.imag"), .Exps))
         , "hexversion": 50528496
         , "implementation" : ref("sys.implementation")(tuple("kpython", ref("sys.version_info")(tuple(1, 0, 0, "alpha", 1)), 16777377 /* 0x010000A1 */, ref("None")))
         , "meta_path": [.Exps]
         , "modules" : {.KeyData}
         , "path" : [DeListify(L)]
         , "path_hooks" : [.Exps]
         , "path_importer_cache" : {.KeyData}
         , "platform" : Constants("sys.platform")
         , "version" : "3.3.0 (kpython version 1.0.0a1)"
         , "version_info" : ref("sys.version_info")(tuple(3, 3, 0, "final", 0))
         }) ~>
         module "types"({
           "BuiltinFunctionType" : ref("builtin-function")
         , "BuiltinMethodType" : ref("builtin-method")
         , "CodeType" : ref("code")
         , "FrameType" : ref("frame")
         , "FunctionType" : ref("function")
         , "GetSetDescriptorType" : ref("attribute")
         , "LambdaType" : ref("function")
         , "MemberDescriptorType" : ref("attribute")
         , "MethodType" : ref("method")
         , "ModuleType" : ref("module")
         , "TracebackType" : ref("traceback")
         })
       ) ...</k>
       <sysPath> L:List </sysPath>
       <environ> M:Map </environ>
       <constants> Constants:Map </constants>

endmodule
