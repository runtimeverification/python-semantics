module MACHINE-INTEGERS

  syntax Int ::= "mult" "(" Int "," Int "," Nat ")" [:function:]
  define mult(I:Int, I2:Int, N:Nat) => wrap(I *Int I2, N)

  syntax Int ::= "wrap" "(" Int "," Nat ")" [:function:]
  define wrap(I, N) => (I &Int maxInt(N)) |Int (0 -Int (I &Int sign(N)))

  syntax Int ::= "sign" "(" Nat ")" [:function:]
  define sign(N) => 1 <<Int (N -Int 1)

  syntax Int ::= "maxInt" "(" Nat ")" [:function:]
  define maxInt(N) => sign(N) -Int 1

end module
