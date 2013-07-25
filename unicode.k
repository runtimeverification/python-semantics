module UNICODE

  syntax Int ::= codePoint(String, Encoding, Int) [function]
               | codePointLength(String) [function]
               | decode(String, Encoding) [function]
               | decodeContinuation(String) [function]
               | length(String, Encoding) [function]
  syntax String ::= bytes(String, Encoding, Int) [function]
  syntax Encoding ::= "UTF-8"

  rule codePoint(S, E, I) => decode(bytes(S, E, I), E)

  rule decode(S, UTF-8) => ordChar(S) &Int 127 when lengthString(S) ==Int 1
  rule decode(S, UTF-8) => ((ordChar(substrString(S, 0, 1)) &Int 31) <<Int 6) +Int decodeContinuation(substrString(S, 1, 2)) when lengthString(S) ==Int 2
  rule decode(S, UTF-8) => ((ordChar(substrString(S, 0, 1)) &Int 15) <<Int 12) +Int decodeContinuation(substrString(S, 1, 3)) when lengthString(S) ==Int 3
  rule decode(S, UTF-8) => ((ordChar(substrString(S, 0, 1)) &Int 7) <<Int 18) +Int decodeContinuation(substrString(S, 1, 4)) when lengthString(S) ==Int 4
  rule decodeContinuation(S) => ordChar(substrString(S, lengthString(S) -Int 1, lengthString(S))) &Int 63 +Int decodeContinuation(substrString(S, 0, lengthString(S) -Int 1)) *Int 64 when S =/=String ""
  rule decodeContinuation("") => 0

  rule bytes(S, UTF-8, 0) => substrString(S, 0, codePointLength(substrString(S, 0, 1)))
  rule bytes(S, UTF-8, I) => bytes(substrString(S, codePointLength(substrString(S, 0, 1)), lengthString(S)), UTF-8, I -Int 1) when I >Int 0

  rule codePointLength(S) => 1 when ordChar(S) <Int 128
  rule codePointLength(S) => 2 when ordChar(S) >=Int 192 andBool ordChar(S) <Int 223
  rule codePointLength(S) => 3 when ordChar(S) >=Int 224 andBool ordChar(S) <Int 239
  rule codePointLength(S) => 4 when ordChar(S) >=Int 240 andBool ordChar(S) <Int 247

  rule length(S, UTF-8) => 1 +Int length(substrString(S, codePointLength(substrString(S, 0, 1)), lengthString(S)), UTF-8) when S =/=String ""
  rule length("", _) => 0

endmodule
