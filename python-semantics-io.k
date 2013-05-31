require "python-semantics-boolean-ops.k"

module PYTHON-SEMANTICS-IO
  imports PYTHON-SEMANTICS-BOOLEAN-OPS

  syntax #Id ::= "follow_symlinks"
  rule invokeBuiltin(obj("posix.stat",_), ListItem(O:Object), .) => ref("posix.stat")(O, follow_symlinks=ref("True"))
  rule invokeBuiltin(obj("posix.stat",_), ListItem(O:Object), "follow_symlinks" |-> Follow:Object) => test(istype(O, ref("str")), if Follow : makeStat(#stat(strvalue(O)), strvalue(O)) else: makeStat(#lstat(strvalue(O)), strvalue(O)), test(istype(O, ref("int")), ?FileDescriptor:Exp, raiseInternal("TypeError", "integer or string is required")))

  syntax K ::= makeStat(KList, String) [function]
  syntax K ::= raiseOSError(K, String) [function]

  rule makeStat(Error:TCPError,File) => raiseOSError(Error, File)
  rule makeStat(MTime:Int,,ATime:Int,,_:K,,IsReg:Bool,,IsDir:Bool,,IsLnk:Bool,,Size:Int,,Dev:Int,,Ino:Int,,Group:Int,,Owner:Int,,Permissions:Int,_) => ref("posix.stat_result")(tuple(?Mode:Int &Int 3584 /* 0o7000 */ |Int fileType(IsReg, IsDir, IsLnk) |Int Permissions, Ino, Dev, ?NLink:Int, Owner, Group, Size, Int2Float(ATime) /Float 1000.0, Int2Float(MTime) /Float 1000.0, ?CTime:Float))

  rule <k> raiseOSError(#ENOENT,File) => raiseInternal("FileNotFoundError", "No such file or directory: '" +String File +String "'", tuple(Errno, ?Msg:String)) ...</k>
       <constants>... "errno.ENOENT" |-> Errno ...</constants>
  rule <k> raiseOSError(#ENOTDIR,File) => raiseInternal("NotADirectoryError", "Not a directory: '" +String File +String "'", tuple(Errno, ?Msg:String)) ...</k>
       <constants>... "errno.ENOTDIR" |-> Errno ...</constants>
  rule <k> raiseOSError(#EACCES,File) => raiseInternal("PermissionError", "Permission denied: '" +String File +String "'", tuple(Errno, ?Msg:String)) ...</k>
       <constants>... "errno.EACCES" |-> Errno ...</constants>
  rule <k> raiseOSError(#ELOOP,File) => raiseInternal("OSError", "Too many levels of symbolic links: '" +String File +String "'", tuple(Errno, ?Msg:String)) ...</k>
       <constants>... "errno.ELOOP" |-> Errno ...</constants>
  rule <k> raiseOSError(#ENAMETOOLONG,File) => raiseInternal("OSError", "File name too long: '" +String File +String "'", tuple(Errno, ?Msg:String)) ...</k>
       <constants>... "errno.ENAMETOOLONG" |-> Errno ...</constants>

  syntax Int ::= fileType(Bool, Bool, Bool) [function]
  rule fileType(true, false, false) => 32768 //S_IFREG
  rule fileType(false, true, false) => 16384 //S_IFDIR
  rule fileType(false, false, true) => 40960 //S_IFLNK
  rule fileType(false, false, false) => ?FileType:Int &Int 61440 // 0o170000


  //simplification rules for bitwise math in this file. needed to avoid using smt for mode arithmetic
  rule (A:Int |Int B:Int) &Int C:Int => A &Int C when B &Int C ==Int 0
  rule (A:Int |Int B:Int) &Int C:Int => B &Int C when A &Int C ==Int 0
  rule (A:Int &Int B:#Int) &Int C:#Int => A &Int (B &Int C)
  rule A:Int &Int 0 => 0
  rule (A:Int |Int B:#Int) |Int C:#Int => A |Int (B |Int C)
  rule A:Int |Int 0 => A

  rule invokeBuiltin(obj("posix.listdir",_), ., .) => ref("posix.listdir")(".")
  //this rule abuses K a little bit because I am putting a function which can rewrite into a raise statement into a list display, which should rightly only contain expressions. but it works correctly, and that's what I care about
  //we also, strangely, are concatenating a string with the empty string, seemingly doing nothing. The reason we do this is to make the two #opendir calls be distinct terms in Maude's internal representation, because of a bug that causes it to try to use the same open socket for both connections
  rule invokeBuiltin(obj("posix.listdir",_), ListItem(Path), .) => test(istype(Path, ref("str")), [ makeListdir(#opendir(strvalue(Path)), ref("str"), strvalue(Path)) ], test(istype(Path, ref("bytes")), [ makeListdir(#opendir(strvalue(Path) +String ""), ref("bytes"), strvalue(Path)) ], test(istype(Path, ref("int")), ?FileDescriptor:Exp, raiseInternal("TypeError", "int, str, or bytes expected"))))

  syntax K ::= makeListdir(KList, Exp, String) [function]

  rule makeListdir(Error:TCPError,_,File) => raiseOSError(Error, File)
  rule makeListdir(S:String ,, Kl:KList, Type, File) => immutable(S, Type), makeListdir(Kl, Type, File)
  rule makeListdir(.KList, _, _) => .Exps

  syntax #Id ::= "write" | "read" | "extend" | "seek" | "readline" | "readall" | "readinto" 
  syntax #Id ::= "DEFAULT_BUFFER_SIZE"
  rule invokeBuiltin(obj("_IOBase.__new__",_), ListItem(Cls) L:List, M:Map) => newHelper(Cls, ref("_IOBase"), SetItem("FileIO") SetItem("BytesIO") SetItem("BufferedReader") SetItem("BufferedWriter") SetItem("BufferedRandom") SetItem("BufferedRWPair") SetItem("TextIOWrapper") SetItem("StringIO") SetItem("IncrementalNewlineDecoder")) ~> mutable("closed" |-> ref("False"), Cls)
  rule invokeBuiltin(obj("_IOBase.__iter__",_), ListItem(Self), .) => Self
  rule invokeBuiltin(obj("_IOBase.close",_), ListItem(Self), .) => if getref(Self, "closed"): pass else: (Self . String2Id("flush")(.Arguments) ; ~> setref(id(Self), "closed", ref("True"))) ~> ref("None")
  rule invokeBuiltin(obj("_IOBase.__enter__",_), ListItem(Self), .) => if getref(Self, "closed") : raiseInternal("ValueError", "I/O operation on closed file") else: Self
  rule invokeBuiltin(obj("_IOBase.__exit__",_), ListItem(Self:Object) L:List, M:Map) => ref("_IOBase.close")(Self)
  rule invokeBuiltin(obj("_IOBase.flush",_), ListItem(Self), .) => if getref(Self, "closed"): raiseInternal("ValueError", "I/O operation on closed file") else: ref("None")
  rule invokeBuiltin(obj("_IOBase.isatty",_), ListItem(Self), .) => if getref(Self, "closed"): raiseInternal("ValueError", "I/O operation on closed file") else: ref("False")
  rule invokeBuiltin(obj("_IOBase.readable",_), ListItem(Self), .) => ref("False")
  rule invokeBuiltin(obj("_IOBase.seekable",_), ListItem(Self), .) => ref("False")
  rule invokeBuiltin(obj("_IOBase.writable",_), ListItem(Self), .) => ref("False")
  rule invokeBuiltin(obj("_IOBase.writelines",_), ListItem(Self) ListItem(Lines:Object), .) => if getref(Self, "closed") : raiseInternal("ValueError", "I/O operation on closed file") else: try: writelines(ref("iter")(Lines), Self) except ref("StopIteration"): ref("None")
  syntax K ::= writelines(Exp, Exp) [strict]
  //we write an explicit freezer here because we need to evaluate O.__next__ *before* evaluating
  //Self.write, otherwise if write isn't defined, we will get an AttributeError instead of a
  //StopIteration
  rule writelines(O:Object, Self) => doWrite(O.__next__(.Arguments), Self) ~> writelines(O, Self)
  syntax K ::= doWrite(Exp, Exp) [strict]
  rule doWrite(O:Object, Self) => Self . write(O) ;
  rule invokeBuiltin(obj("_IOBase.fileno",_), ListItem(Self), .) => raise ref("UnsupportedOperation")("fileno")
  rule invokeBuiltin(obj("_IOBase.readline",_), ListItem(Self), .) => ref("_IOBase.readline")(Self, ref("None"))
  rule invokeBuiltin(obj("_IOBase.readline",_), ListItem(Self) ListItem(Limit), .) => test(Limit is None, readLine(Self, -1), readLine(Self, ref(id(Limit))))
  syntax K ::= readLine(Exp, Exp) [strict(1)]
  rule readLine(S, L) => ref("index")(L ::Exp) ~> readLine(S, HOLE) when isInt(L) =/=K true [heat]
  rule O ~> readLine(S, HOLE) => readLine(S, intvalue(O)) [cool]
  rule readLine(Self, Limit:Int) => test(Limit ==Int 0, b "", readLine(Self, Limit, Self . read(1)))
  syntax K ::= readLine(Exp, Int, Exp) [strict(1, 3)]
  rule readLine(Self, Limit, ReadByte:Object) => test(istype(ReadByte, ref("bytes")), test(strvalue(ReadByte) ==String "\n" orBool strvalue(ReadByte) ==String "", ReadByte, ReadByte + readLine(Self, Limit -Int 1)), raiseInternal("OSError", "read() should have returned a bytes object"))
  rule invokeBuiltin(obj("_IOBase.readlines",_), ListItem(Self), .) => ref("_IOBase.readlines")(Self, ref("None"))
  rule invokeBuiltin(obj("_IOBase.readlines",_), ListItem(Self) ListItem(Hint), .) => if getref(Self, "closed"): raiseInternal("ValueError", "I/O operation on closed file") else: test(Hint is None, readLines(Self, -1, [.Exps]), readLines(Self, ref(id(Hint)), [.Exps]))
  syntax K ::= readLines(Exp, Exp, Exp) [strict(1, 3)]
  rule readLines(S, L, R) => ref("index")(L ::Exp) ~> readLines(S, HOLE, R) when isInt(L) =/=K true [heat]
  rule O ~> readLines(S, HOLE, R) => readLines(S, intvalue(O), R) [cool]
  rule readLines(Self, Hint:Int, List:Object) => try: List . extend(Self . __next__(.Arguments)) ; except ref("StopIteration"): ref(id(List)) else: if Hint - ref("len")(List[-1]) < 0 and bool(Hint >=Int 0) : ref(id(List)) else: readLines(Self, Hint - ref("len")(List[-1]), List)

  rule invokeBuiltin(obj("_IOBase.seek",_), ListItem(Self) L:List, M:Map) => raise ref("UnsupportedOperation")("seek")
  rule invokeBuiltin(obj("_IOBase.tell",_), ListItem(Self), .) => Self . seek(0, 1)
  rule invokeBuiltin(obj("_IOBase.truncate",_), ListItem(Self) L:List, M:Map) => raise ref("UnsupportedOperation")("truncate")
  rule invokeBuiltin(obj("_IOBase.__next__",_), ListItem(Self), .) => checkLineLength(Self . readline(.Arguments))
  syntax Exp ::= checkLineLength(Exp) [strict]
  rule checkLineLength(Line:Object) => if ref("len")(Line) == 0: raise ref("StopIteration") else: Line

  rule invokeBuiltin(obj("_RawIOBase.read",_), ListItem(Self), .) => ref("_RawIOBase.read")(Self, -1)
  rule invokeBuiltin(obj("_RawIOBase.read",_), ListItem(Self) ListItem(N), .) => doRead(Self, ref(id(N)))
  syntax Exp ::= doRead(Exp, Exp) [strict(1)]
  rule doRead(S, N) => N ~> doRead(S, HOLE) when isInt(N) =/=K true [heat]
  rule O ~> doRead(S, HOLE) => doRead(S, intvalue(O)) [cool]
  rule doRead(Self, N:Int) => test(N <Int 0, Self . readall(.Arguments), doRead(Self, N, ref("bytearray")(N)))
  syntax Exp ::= doRead(Exp, Int, Exp) [strict(1, 3)]
  rule doRead(Self, _, ByteArray:Object) => Self . readinto(ByteArray) ; ~> ref("bytes")(ref(id(ByteArray)))
  rule invokeBuiltin(obj("_RawIOBase.readall",_), ListItem(Self), .) => readAll(Self . read(ref("_io") . DEFAULT_BUFFER_SIZE), b "", Self)
  syntax Exp ::= readAll(Exp, Exp, Exp) [strict]
  rule readAll(O:Object, Bytes, Self) => test(O is None, test(strvalue(Bytes) ==String "", ref("None"), Bytes), test(istype(O, ref("bytes")), test(strvalue(O) ==String "", Bytes, readAll(Self . read(ref("_io") . DEFAULT_BUFFER_SIZE), Bytes + O, Self)), raiseInternal("TypeError", "read() should return bytes")))
endmodule
