module PYTHON-TOKENS
  imports COMPLEX-NUMBERS
  imports BYTES

  //TODO: redo with hooks

  syntax NAME ::= Id
  syntax NUMBER ::= Int | Float | Imaginary
  syntax STRING ::= String | Bytes
  syntax NAMES ::= List{NAME,","} [seqstrict]
endmodule

module PYTHON-SYNTAX imports PYTHON-TOKENS

  syntax Atom ::= NAME
                | NUMBER
                | STRING
                | "tuple" "(" Expressions ")" [strict]
                | "[" Expression CompIter "]"
                | "generator" "(" Expression CompIter ")"
                | "{" Expression CompIter "}"
                | "{" Expression ":" Expression CompIter "}"
                | "[" Expressions "]" [strict]
                | "{" KeyData "}" [strict]
                | "{" Expressions "}" [strict]
                | YieldExpression
                | "..."
  
  syntax CompFor ::= "for" Targets "in" Expressions
  syntax CompIf ::= "if" "(" Expression ")"
  syntax CompIter ::= CompFor
                    | CompIf
                    | CompIter "@" CompIter

  syntax YieldExpression ::= "yield" Expression [strict] 
                           | "yield"
  syntax KeyData ::= List{KeyDatum,","} [seqstrict]
  syntax KeyDatum ::= Expression ":" Expression [seqstrict, hybrid]

  syntax Primary ::= AttributeRef
                   | Subscription
                   | Expression "(" Arguments ")" [seqstrict]

  syntax Arguments ::= List{Argument,","}
  syntax Argument ::= Expression
                    | NAME "=" Expression [strict(2)]
                    // "*" Expression is implicit
                    | "**" Expression [strict, hybrid]

  syntax AttributeRef ::= Expression "." NAME [strict(1), left]

  syntax Subscription ::= Expression "[" Expression "]" [seqstrict]
  syntax Slice ::= ":" ":"
                 | Expression ":" ":"
                 | ":" Expression ":"
                 | ":" ":" Expression
                 | Expression ":" Expression ":" [seqstrict]
                 | Expression ":" ":" Expression [seqstrict]
                 | ":" Expression ":" Expression [seqstrict]
                 | Expression ":" Expression ":" Expression [seqstrict]

  syntax AExp ::= Expression "**" Expression     [seqstrict, right]
                > "-" Expression                 [strict]
                | "+" Expression                 [strict]
                | "~" Expression                 [strict]
                > Expression "*" Expression      [seqstrict, left]
                | Expression "floor/" Expression [seqstrict, left]
                | Expression "/" Expression      [seqstrict, left]
                | Expression "%" Expression      [seqstrict, left]
                > Expression "+" Expression      [seqstrict, left]
                | Expression "-" Expression      [seqstrict, left]
                > Expression "<<" Expression     [seqstrict, left]
                | Expression ">>" Expression     [seqstrict, left]
                > Expression "&" Expression      [seqstrict, left]
                > Expression "^" Expression      [seqstrict, left]
                > Expression "|" Expression      [seqstrict, left]

  syntax BExp ::= Expression "<" Expression      [strict(1), right]
                | Expression ">" Expression      [strict(1), right]
                | Expression "==" Expression     [strict(1), right]
                | Expression ">=" Expression     [strict(1), right]
                | Expression "<=" Expression     [strict(1), right]
                | Expression "!=" Expression     [strict(1), right]
                | Expression "is" Expression     [strict(1), right]
                | Expression "is not" Expression [strict(1), right]
                | Expression "in" Expression     [strict(1), right]
                | Expression "not in" Expression [strict(1), right]
                > "not" Expression               [strict]
                > Expression "and" Expression    [strict(1), left]
                > Expression "or" Expression     [strict(1), left]
                > Expression "if" Expression "else" Expression [strict(2)]

  syntax Expression ::= Atom
                      > Primary
                      > AExp
                      > BExp
                      > "lambda" Parameters ":" Expression
                      | "*" Expression [strict, hybrid]
                      | "(" Expression ")" [bracket]

  syntax Expressions ::= List{Expression,","}

  syntax SimpleStmt ::= Expression ";" [strict]
                      | Targets ":=" Expression     [strict(2)]
                      | Target "+=" Expression      [strict(2)]
                      | Target "-=" Expression      [strict(2)]
                      | Target "*=" Expression      [strict(2)]
                      | Target "/=" Expression      [strict(2)]
                      | Target "floor/=" Expression [strict(2)]
                      | Target "%=" Expression      [strict(2)]
                      | Target "**=" Expression     [strict(2)]
                      | Target ">>=" Expression     [strict(2)]
                      | Target "<<=" Expression     [strict(2)]
                      | Target "&=" Expression      [strict(2)]
                      | Target "^=" Expression      [strict(2)]
                      | Target "|=" Expression      [strict(2)]
                      | "assert" Expressions
                      | "pass"
                      | "del" Targets
                      | "return" Expression [strict]
                      | "return"
                      | "raise"
                      | "raise" Expression [strict]
                      | "raise" Expression "from" Expression [seqstrict]
                      | "break"
                      | "continue"
                      | "import" ModuleAliases [seqstrict]
                      | "from" RelativeModule "import" ModuleAliases [strict(1)]
                      | "from" Primary "import" "*" [strict]
                      | "global" NAMES
                      | "nonlocal" NAMES

  syntax Targets ::= Expressions 
  syntax Target ::= Expression
  
  syntax ModuleAliases ::= List{ModuleAlias,","}
  syntax ModuleAlias ::= Expression
                       | Expression "as" NAME
  syntax RelativeModule ::= ".dir"
                          | Expression
                          | "." RelativeModule

  syntax ExceptClauses ::= ExceptClause
                         | ExceptClause ExceptClauses

  syntax CompoundStmt ::= "if" Expression ":" Statements "else" ":" Statements [strict(1)]
                        | "while" Expression ":" Statements "else" ":" Statements
                        | "for" Targets "in" Expressions ":" Statements "else" ":" Statements
                        | "try" ":" Statements ExceptClauses "else" ":" Statements //"finally" ":" Statements
                        | "try" ":" Statements "finally" ":" Statements
                        | "with" Expression "as" Target ":" Statements
                        | Decorated

  syntax Statement ::= SimpleStmt
                     > CompoundStmt

  syntax Statements ::= Statement
                      > Statement "newline" Statements 

  syntax ExceptClause ::= "except" ":" Statements
                        | "except" Expression ":" Statements [strict(1)]
                        | "except" Expression "as" NAME ":" Statements [strict(1)]

  syntax Decorated ::= ClassDef
                     | FuncDef
                     | "@" Primary Decorated [strict(1)]

  syntax Parameters ::= List{Parameter,","} [seqstrict]
  syntax Parameter ::= Argument
                     | KeyDatum
                     | Argument ":" Expression
                     | "*"

  syntax FuncDef ::= "def" NAME "(" Parameters ")" "->" Expression ":" Statements
                   | "def" NAME "(" Parameters ")" ":" Statements


  syntax ClassDef ::= "class" NAME "(" Arguments ")" ":" Statements

endmodule
