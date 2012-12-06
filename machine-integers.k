module MACHINE-INTEGERS

  syntax Int ::= mult(Int, Int, Int) [function]
  rule mult(I:Int, I2:Int, N:Nat) => wrap(I *Int I2, N) [function, anywhere]

  syntax Int ::= add(Int, Int, Int) [function]
  rule add(I, I2, N) => wrap(I +Int I2, N)

  syntax Int ::= wrap(Int, Int) [function]
  rule wrap(I, N) => (I &Int maxInt(N)) |Int (0 -Int (I &Int sign(N))) [function, anywhere]

  syntax Int ::= sign(Int) [function]
  rule sign(N) => 1 <<Int (N -Int 1) [function, anywhere]

  syntax Int ::= maxInt(Int) [function]
  rule maxInt(N) => sign(N) -Int 1 [function, anywhere]

  syntax Int ::= lcgRandom(Int, Int, Int) [function]

  rule lcgRandom(Seed, I, Width) => ((add(mult(Seed, 214013, Width), 2531011, Width) >>Int 16) &Int 255) +Int (lcgRandom(add(mult(Seed, 214013, Width), 2531011, Width), I -Int 1, Width) <<Int 8) when I >Int 0
  rule lcgRandom(_, 0, _) => 0

endmodule
