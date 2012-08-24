module MACHINE-INTEGERS

  syntax Int ::= "mult" "(" Int "," Int "," Nat ")" [function]
  rule mult(I:Int, I2:Int, N:Nat) => wrap(I *Int I2, N) [function, anywhere]

  syntax Int ::= "wrap" "(" Int "," Nat ")" [function]
  rule wrap(I, N) => (I &Int maxInt(N)) |Int (0 -Int (I &Int sign(N))) [function, anywhere]

  syntax Int ::= "sign" "(" Nat ")" [function]
  rule sign(N) => 1 <<Int (N -Int 1) [function, anywhere]

  syntax Int ::= "maxInt" "(" Nat ")" [function]
  rule maxInt(N) => sign(N) -Int 1 [function, anywhere]

endmodule
