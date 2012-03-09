module MACHINE-INTEGERS

  declare mult : #Int #Int #Nat -> #Int
  define mult(I:#Int, I2:#Int, N:#Nat) => wrap(I *Int I2, N)

  declare wrap : #Int #Nat -> #Int
  define wrap(I, N) => (I &Int maxInt(N)) |Int -Int (I &Int sign(N))

  declare sign : #Nat -> #Int
  define sign(sNat(N)) => 1 <<Int N

  declare maxInt : #Nat -> #Int
  define maxInt(N) => sign(N) -Int 1

end module
