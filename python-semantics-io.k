require "python-semantics-common.k"

module PYTHON-SEMANTICS-IO
  imports PYTHON-SEMANTICS-COMMON

  syntax #Id ::= "follow_symlinks"
  rule invokeBuiltin(obj("posix.stat",_), ListItem(O:Object), .) => ref("posix.stat")(O, follow_symlinks=ref("True"))
  rule invokeBuiltin(obj("posix.stat",_), ListItem(O:Object), "follow_symlinks" |-> Follow:Object) => test(istype(O, ref("str")), if Follow : makeStat(#stat(strvalue(O)), strvalue(O)) else: makeStat(#lstat(strvalue(O)), strvalue(O)), test(istype(O, ref("int")), stuck, raiseInternal("TypeError", "integer or string is required")))

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
  rule invokeBuiltin(obj("posix.listdir",_), ListItem(Path), .) => test(istype(Path, ref("str")), [ makeListdir(#opendir(strvalue(Path)), ref("str"), strvalue(Path)) ], test(istype(Path, ref("bytes")), [ makeListdir(#opendir(strvalue(Path) +String ""), ref("bytes"), strvalue(Path)) ], test(istype(Path, ref("int")), stuck, raiseInternal("TypeError", "int, str, or bytes expected"))))

  syntax K ::= makeListdir(KList, Exp, String) [function]

  rule makeListdir(Error:TCPError,_,File) => raiseOSError(Error, File)
  rule makeListdir(S:String ,, Kl:KList, Type, File) => immutable(S, Type), makeListdir(Kl, Type, File)
  rule makeListdir(.KList, _, _) => .Exps

endmodule
