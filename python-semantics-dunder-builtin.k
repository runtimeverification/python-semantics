module PYTHON-SEMANTICS-DUNDER-BUILTIN
  imports PYTHON-SEMANTICS-BUILTIN-MODULES

  rule <k> builtins => (
         object "builtins"(
           "module",.,
           "AssertionError" |-> "AssertionError"
           "AttributeError" |-> "AttributeError"
           "BaseException" |-> "BaseException"
           "Exception" |-> "Exception"
           "False" |-> "False"
           "IndexError" |-> "IndexError"
           "KeyError" |-> "KeyError"
           "LookupError" |-> "LookupError"
           "NameError" |-> "NameError"
           "None" |-> "None"
           "NotImplemented" |-> "NotImplemented"
           "RuntimeError" |-> "RuntimeError"
           "StopIteration" |-> "StopIteration"
           "SyntaxError" |-> "SyntaxError"
           "True" |-> "True"
           "TypeError" |-> "TypeError"
           "__debug__" |-> "__debug__"
           "bool" |-> "bool"
           "complex" |-> "complex"
           "dict" |-> "dict"
           "hash" |-> "hash"
           "int" |-> "int"
           "iter" |-> "iter"
           "float" |-> "float"
           "len" |-> "len"
           "list" |-> "list"
           "object" |-> "object"
           "str" |-> "str"
           "tuple" |-> "tuple"
           "type" |-> "type",
           "__debug__" |-> ref("True")) ~>
         object "__debug__" ("attribute",.,.,.) ~>
         object "sys"(
           "module",.,
           "hash_info" |-> "hash_info" ,
           "hash_info" |-> list(ListItem(64) ListItem(2305843009213693951) ListItem(314159) ListItem(0) ListItem(1000003))) ~>
         object "hash_info" ("attribute",.,.,.) ~>
         object "AssertionError"("type",ListItem("Exception"),.,.) ~>
         object "AttributeError"("type",ListItem("Exception"),.,.) ~>
         object "BaseException"("type",ListItem("object"),
           "__cause__" |-> "__cause__"
           "__context__" |-> "__context__"
           "__init__" |-> def "init_baseexception" (0, -1, true)
           ,.) ~>
         object "__cause__" ("reference",.,.,.) ~>
         object "__context__" ("reference",.,.,.) ~>
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
         object "bool"("type",ListItem("int"),
           "__new__" |-> def "new_bool" (1, 2, false)
           ,.) ~>
         object "complex"("type",ListItem("object"),.,.) ~>
         object "dict"("type",ListItem("object"),
           "keys" |-> def "keys_dict" (0, 0, true)
           "__getitem__" |-> def "getitem_dict" (1, 1, true)
           "__init__" |-> def "init_dict" (0, 1, true)
           "__len__" |-> def "len_dict" (0, 0, true)
           "__new__" |-> def "new_dict" (1, -1, false)
           ,.) ~>
         object "dict_keys" ("type",ListItem("object"),
           "__iter__" |-> def "iter_dict_keys" (0, 0, true)
           ,.) ~>
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
           //TODO: hash, index
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
           "__new__" |-> def "new_raise" (1, -1, false)
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
         object "module"("type",ListItem("object"),
           "__getattribute__" |-> def "getattribute_module" (1, 1, true)
           ,.) ~>
         object "object"("type",root,
           "__class__" |-> "__class__"
           "__getattribute__" |-> def "getattribute_object" (1, 1, true)
           "__eq__" |-> def "eq_object" (0, 1, true)
           "__init__" |-> def "init_object" (0, -1, true)
           "__ne__" |-> def "ne_object" (1, 1, true)
           "__new__" |-> def "new_object" (1, -1, false)
           ,.) ~>
         object "__class__" ("reference",.,.,.) ~>
         object "str"("type",ListItem("object"),
           "__add__" |-> def "add_str" (1, 1, true)
           "__eq__" |-> def "eq_str" (1, 1, true)
           "__hash__" |-> def "hash_str" (1, 1, true)
           "__ne__" |-> def "ne_str" (1, 1, true)
           "__radd__" |-> def "radd_str" (1, 1, true)
           ,.) ~>
         object "tuple"("type",ListItem("object"),
           "__add__" |-> def "add_tuple" (1, 1, true)
           "__getitem__" |-> def "getitem_tuple" (1, 1, true)
           "__iter__" |-> "get_iter"
           "__len__" |-> def "len_tuple" (0, 0, true)
           "__new__" |-> def "new_tuple" (1, 2, false)
           ,.) ~>
         object "type"("type",ListItem("object"),
           "__call__" |-> def "call_type" (1, -1, true)
           "__name__" |-> "__name__" ,.) ~>
         object "__name__" ("attribute",.,.,.) ~>
         object "attribute"("type",ListItem("object"),
           "__get__" |-> def "get_attr" (1, 2, true)
           "__new__" |-> "new_raise"
           , "__name__" |-> undefined("internal type name")) ~>
         object "reference"("type",ListItem("object"),
           "__get__" |-> def "get_ref" (1, 2, true)
           "__new__" |-> "new_raise"
           , "__name__" |-> undefined("internal type name")) ~>
         object "builtin-method" ("type",ListItem("object"),
           "__call__" |-> "call_builtin_function"
           "__get__" |-> def "get_builtin_method" (1, 2, true)
           "__new__" |-> "new_raise"
           , "__name__" |-> undefined("internal type name")) ~>
         object "builtin-function" ("type",ListItem("object"),
           "__call__" |-> def "call_builtin_function" (0, -1, true)
           "__new__" |-> "new_raise"
           , "__name__" |-> undefined("internal type name")) ~>
         object "function"("type",ListItem("object"),
           "__call__" |-> def "call_function" (0, -1, true)
           ,.) ~>
         object "method" ("type", ListItem("object"),
           "__call__" |-> def "call_method" (0, -1, true)
           "__func__" |-> "__func__"
           "__self__" |-> "__self__"
           , .) ~>
         object "__func__" ("attribute",.,.,.) ~>
         object "__self__" ("attribute",.,.,.) ~>
         genv( "__builtins__" , "builtins" )
       ) ...</k>

end module
