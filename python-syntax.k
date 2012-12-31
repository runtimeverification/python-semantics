require "complex-numbers.k"
require "bytes.k"

module PYTHON-TOKENS
  imports COMPLEX-NUMBERS
  imports BYTES

  syntax NAME ::= Id
  syntax NUMBER ::= Int | Float | Imaginary
  syntax STRING ::= String | Bytes
  syntax NAMES ::= List{NAME,","} [seqstrict, hybrid]
endmodule

module PYTHON-SYNTAX imports PYTHON-TOKENS

  syntax CompFor ::= "for" Targets "in" Expressions
  syntax CompIf ::= "if" Expression
  syntax Comp ::= CompFor
                | CompIf
  syntax Comps ::= List{Comp,"@"}


  syntax YieldExpression ::= "yield" Expression [strict] 
                           | "yield"
  syntax KeyData ::= List{KeyDatum,","} [seqstrict]
  syntax KeyDatum ::= Expression ":" Expression [seqstrict, hybrid]

  syntax Arguments ::= List{Argument,","}
  syntax Argument ::= Expression
                    | NAME "=" Expression [strict(2)]
                    // "*" Expression is implicit
                    | "**" Expression [strict, hybrid]

  syntax Expression ::= ":" ":"
                      | Expression ":" ":"
                      | ":" Expression ":"
                      | ":" ":" Expression
                      | Expression ":" Expression ":" [seqstrict]
                      | Expression ":" ":" Expression [seqstrict]
                      | ":" Expression ":" Expression [seqstrict]
                      | Expression ":" Expression ":" Expression [seqstrict]

  syntax Expression ::= "(" Expression ")" [bracket]
                | NAME
                | NUMBER
                | STRING
                | "tuple" "(" Expressions ")" [strict]
                | "[" Expression Comps "]"
                | "generator" "(" Expression Comps ")"
                | "{" Expression Comps "}"
                | "{" Expression ":" Expression Comps "}"
                | "[" Expressions "]" [strict]
                | "{" KeyData "}" [strict]
                | "{" Expressions "}" [strict, klabel('Set)]
                | YieldExpression
                | "..."

                   > Expression "." NAME           [strict(1), left]
                   | Expression "[" Expression "]" [seqstrict, left]
                   | Expression "(" Arguments ")"  [seqstrict, left]

                 > Expression "**" Expression [seqstrict, right]

                 > "-" Expression [strict]
                 | "+" Expression [strict]
                 | "~" Expression [strict]

                 > Expression "*" Expression      [seqstrict, left]
                 | Expression "floor/" Expression [seqstrict, left]
                 | Expression "/" Expression      [seqstrict, left]
                 | Expression "%" Expression      [seqstrict, left]

                 > Expression "+" Expression [seqstrict, left]
                 | Expression "-" Expression [seqstrict, left]

                     > Expression "<<" Expression [seqstrict, left]
                     | Expression ">>" Expression [seqstrict, left]

                   > Expression "&" Expression [seqstrict, left]

                   > Expression "^" Expression [seqstrict, left]

                  > Expression "|" Expression [seqstrict, left]

                      > Expression "<" Expression        [right]
                      | Expression ">" Expression        [right]
                      | Expression "==" Expression       [right]
                      | Expression ">=" Expression       [right]
                      | Expression "<=" Expression       [right]
                      | Expression "!=" Expression       [right]
                      | Expression "is" Expression       [right]
                      | Expression "is" "not" Expression [right]
                      | Expression "in" Expression       [right]
                      | Expression "not" "in" Expression [right]

                   > "not" Expression [strict]

                   > Expression "and" Expression [strict(1), left]

                  > Expression "or" Expression [strict(1), left]

                      > Expression "if" Expression "else" Expression [strict(2), right]
                      > "lambda" Parameters ":" Expression
                      | "*" Expression [strict, hybrid, non-assoc]

  syntax Expressions ::= List{Expression,","}

  syntax Targets ::= Expressions 
  syntax Target ::= Expression
  
  syntax Aliases ::= List{Alias,","}
  syntax Alias ::= Expression
                       | Expression "as" Expression [strict(1)]
  syntax RelativeModule ::= ".dir"
                          | Expression
                          | "." RelativeModule

  syntax ExceptClauses ::= List{ExceptClause,"except"}

  syntax Statement ::= Expression ";" [strict]
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
                     | "import" Aliases
                     | "from" RelativeModule "import" Aliases
                     | "from" Expression "import" "*"
                     | "global" NAMES
                     | "nonlocal" NAMES
                     > "if" Expression ":" Statements "else" ":" Statements [strict(1)]
                     | "while" Expression ":" Statements "else" ":" Statements
                     | "for" Targets "in" Expressions ":" Statements "else" ":" Statements
                     | "try" ":" Statements ExceptClauses "else" ":" Statements //"finally" ":" Statements
                     | "try" ":" Statements ExceptClauses "else" ":" Statements "finally" ":" Statements
                     | "try" ":" Statements "finally" ":" Statements
                     | "with" Aliases ":" Statements [strict(1)]
                     | Decorated

  syntax Statements ::= Statement
                      > Statement "newline" Statements 

  syntax ExceptClause ::= "except" ":" Statements
                        | "except" Expression ":" Statements [strict(1)]
                        | "except" Expression "as" NAME ":" Statements [strict(1)]

  syntax Decorated ::= ClassDef
                     | FuncDef
                     | "@" Expression "newline" Decorated [strict(1)]

  syntax Parameters ::= List{Parameter,","} [seqstrict]
  syntax Parameter ::= Argument
                     | KeyDatum
                     | Argument ":" Expression
                     | "*"

  syntax FuncDef ::= "def" NAME "(" Parameters ")" "->" Expression ":" Statements
                   | "def" NAME "(" Parameters ")" ":" Statements


  syntax ClassDef ::= "class" NAME "(" Arguments ")" ":" Statements [strict(2)]

endmodule
