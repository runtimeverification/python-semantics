require "python-semantics-common.k"

module PYTHON-SEMANTICS-IO
  imports PYTHON-SEMANTICS-COMMON

  rule invokeBuiltin(obj("posix.stat",_), ListItem(O:Object), .) => test(istype(O, ref("str")), ref("posix.stat_result")(tuple((?Mode:Int &Int 4095) |Int mode(strvalue(O)), ?Ino:Int, ?Dev:Int, ?NLink:Int, ?Uid:Int, ?Gid:Int, ?Size:Int, ?ATime:Float, mtime(strvalue(O)), ?CTime:Float)), test(istype(O, ref("int")), ref("posix.stat_result")(tuple(?Mode:Int, ?Ino:Int, ?Dev:Int, ?NLink:Int, ?Uid:Int, ?Gid:Int, ?Size:Int, ?ATime:Float, ?MTime:Float, ?CTime:Float)), raiseInternal("TypeError", "integer or string is required")))

  syntax Int ::= mode(String) [function]
  syntax Float ::= mtime(String) [function]

  rule mode(S) => #if #isDir(S) #then 16384 #else #if #isFile(S) #then 32768 #else ?Mode:Int #fi #fi
  rule mtime(S) => Int2Float(#mtimeMillis(S)) /Float 1000.0

  //simplification rule for bitwise math in this file
  rule (A:Int |Int B:Int) &Int C:Int => C when C &Int ~Int B ==Int 0
  rule (A:Int |Int B:Int) &Int C:Int => B when B &Int ~Int C ==Int 0 andBool A &Int C ==Int 0
  rule (A:Int &Int B:#Int) &Int C:#Int => A &Int (B &Int C)
  rule A:Int &Int 0 => 0
endmodule
