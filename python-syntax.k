require "complex-numbers.k"
require "bytes.k"

module PYTHON-TOKENS
  imports COMPLEX-NUMBERS
  imports BYTES

  syntax NAME ::= Id
  syntax NUMBER ::= Int | Float | Imaginary
  syntax STRING ::= String | Bytes
  syntax NAMES ::= NeList{NAME,","} [seqstrict, hybrid]
endmodule

module PYTHON-SYNTAX imports PYTHON-TOKENS

  syntax CompFor ::= "for" Target "in" Exp
  syntax CompIf ::= "if" Exp
  syntax Comp ::= CompFor
                | CompIf
  syntax Comps ::= List{Comp,""}


  syntax YieldExp ::= "yield" Exp [strict] 
                           | "yield"
                           | "yield" "from" Exp [strict]

  syntax KeyData ::= List{KeyDatum,","} [seqstrict]
  syntax KeyDatum ::= Exp ":" Exp [seqstrict, hybrid]

  syntax Arguments ::= List{Argument,","}
  syntax Argument ::= Exp
                    | NAME "=" Exp [strict(2), klabel('keyword)]
                    | "*" Exp [strict, hybrid]
                    | "**" Exp [strict, hybrid]

  //TODO: 2-part slices
  syntax Slice ::= Exp
                 | ":" ":"
                 | Exp ":" ":"
                 | ":" Exp ":"
                 | ":" ":" Exp
                 | Exp ":" Exp ":"
                 | Exp ":" ":" Exp
                 | ":" Exp ":" Exp
                 | Exp ":" Exp ":" Exp

  syntax TargetAndExp ::= NAME
                        | "tuple" "(" TargetAndExps ")" [strict, klabel('Tuple), atom]
                        | "[" TargetAndExps "]" [strict, atom]
                        | Exp "." NAME [strict(1), left, primary]
                        | Exp "[" Slice "]" [seqstrict, left, primary]

  syntax Target ::= TargetAndExp
                  | "*" Target [klabel('Starred)]
                  | "tuple" "(" Targets ")" [klabel('Tuple), primary]
                  | "[" Targets "]" [primary]
  syntax TargetAndExps ::= NeList{TargetAndExp,","}
  syntax Targets ::= List{Target,","}
  syntax NeTargets ::= NeList{Target,","}
  syntax Targets ::= NeTargets
  syntax Exp ::= TargetAndExp

  syntax priorities atom > primary > power


  syntax Exp ::= "(" Exp ")" [bracket, atom]
                | NUMBER [atom]
                | STRING [atom]
                | "tuple" "(" Exps ")" [strict, klabel('Tuple), atom] //TODO: use List{Exp,","}
                | "[" Exp Comps "]" [atom]
                | "generator" "(" Exp Comps ")" [klabel('GeneratorExp), atom] //TODO: Use (__)
                | "{" Exp Comps "}" [atom]
                | "{" Exp ":" Exp Comps "}" [atom]
                | "[" Exps "]" [strict, atom]
                | "{" KeyData "}" [strict, atom]
                | "{" NeExps "}" [strict, klabel('Set), atom]
                | YieldExp [atom]
                | "..." [atom]

                  |  Exp "(" Arguments ")"  [seqstrict, left, primary]

                 > Exp "**" Exp [seqstrict, right, power]

                 > "-" Exp [strict]
                 | "+" Exp [strict]
                 | "~" Exp [strict]

                 > Exp "*" Exp      [seqstrict, left]
                 | Exp "floor/" Exp [seqstrict, left, klabel('_FloorDiv_)] //TODO: use //
                 | Exp "/" Exp      [seqstrict, left]
                 | Exp "%" Exp      [seqstrict, left]

                 > Exp "+" Exp [seqstrict, left]
                 | Exp "-" Exp [seqstrict, left]

                     > Exp "<<" Exp [seqstrict, left]
                     | Exp ">>" Exp [seqstrict, left]

                   > Exp "&" Exp [seqstrict, left]

                   > Exp "^" Exp [seqstrict, left]

                  > Exp "|" Exp [seqstrict, left]

                      > Exp "<" Exp        [right]
                      | Exp ">" Exp        [right]
                      | Exp "==" Exp       [right]
                      | Exp ">=" Exp       [right]
                      | Exp "<=" Exp       [right]
                      | Exp "!=" Exp       [right]
                      | Exp "is" Exp       [right]
                      | Exp "is" "not" Exp [right]
                      | Exp "in" Exp       [right]
                      | Exp "not" "in" Exp [right]

                   > "not" Exp [strict]

                   > Exp "and" Exp [strict(1), left]

                  > Exp "or" Exp [strict(1), left]

                      > Exp "if" Exp "else" Exp [strict(2), right]
                      > "lambda" Parameters ":" Exp

  syntax "*" -/- [\*]

  syntax Exps ::= List{Exp,","}
  syntax Exps ::= NeExps
  syntax NeExps ::= NeList{Exp,","}

  syntax AssignTargets ::= NeList{Target,"="} [klabel('targets)]
  
  syntax Aliases ::= NeList{Alias,","}
  //TODO: separate with from import
  syntax Alias ::= Exp
                       | Exp "as" Exp [strict(1)]
  syntax RelativeModule ::= "." [onlyLabel]
                          | Exp
                          | "." RelativeModule

  syntax ExceptClauses ::= NeList{ExceptClause,""}

  syntax Suite ::= StmtList NEWLINE | NEWLINE INDENT Stmts DEDENT
  syntax Stmt ::= StmtList NEWLINE | CompoundStmt
  syntax Stmts ::= NeList{Stmt,""}

  //TODO: add lexer rules
  syntax NEWLINE
  syntax INDENT
  syntax DEDENT

  syntax SimpleStmt ::= Exp [strict, klabel('Expr), onlyLabel] //TODO: remove onlyLabel
                     | AssignTargets "=" Exp [strict(2)] 
                     | Target "+=" Exp       [strict(2)]
                     | Target "-=" Exp       [strict(2)]
                     | Target "*=" Exp       [strict(2)]
                     | Target "/=" Exp       [strict(2)]
                     | Target "floor/=" Exp  [strict(2), klabel('_FloorDiv=_)] //TODO: use //=
                     | Target "%=" Exp       [strict(2)]
                     | Target "**=" Exp      [strict(2)]
                     | Target ">>=" Exp      [strict(2)]
                     | Target "<<=" Exp      [strict(2)]
                     | Target "&=" Exp       [strict(2)]
                     | Target "^=" Exp       [strict(2)]
                     | Target "|=" Exp       [strict(2)]
                     | "assert" Exp
                     | "assert" Exp "," Exp
                     | "pass"
                     | "del" NeTargets
                     | "return" Exp [strict]
                     | "return"
                     | "raise"
                     | "raise" Exp [strict]
                     | "raise" Exp "from" Exp [seqstrict]
                     | "break"
                     | "continue"
                     | "import" Aliases
                     | "from" RelativeModule "import" Aliases
                     | "from" Exp "import" "*"
                     | "global" NAMES
                     | "nonlocal" NAMES 
                     //TODO: elif
  syntax CompoundStmt ::= "if" Exp ":" Suite
                        | "if" Exp ":" Suite "else" ":" Suite [strict(1)]
                        | "while" Exp ":" Suite
                        | "while" Exp ":" Suite "else" ":" Suite
                        | "for" Target "in" Exp ":" Suite
                        | "for" Target "in" Exp ":" Suite "else" ":" Suite
                        | "try" ":" Suite ExceptClauses
                        | "try" ":" Suite ExceptClauses "else" ":" Suite
                        | "try" ":" Suite ExceptClauses "else" ":" Suite "finally" ":" Suite
                        | "try" ":" Suite "finally" ":" Suite
                        | "with" Aliases ":" Suite [strict(1)]
                        | Decorated

  syntax StmtList ::= List{SimpleStmt,";"}

  syntax ExceptClause ::= "except" ":" Suite
                        | "except" Exp ":" Suite [strict(1)]
                        | "except" Exp "as" NAME ":" Suite [strict(1)]

  syntax Decorated ::= ClassDef
                     | FuncDef
                     | "@" Exp NEWLINE Decorated [strict(1)]

  syntax Parameters ::= List{Parameter,","} [seqstrict]
  syntax Parameter ::= Argument
                     | Argument ":" Exp [klabel('annotation)]
                     | "*"

  syntax FuncDef ::= "def" NAME "(" Parameters ")" "->" Exp ":" Suite
                   | "def" NAME "(" Parameters ")" ":" Suite


  syntax ClassDef ::= "class" NAME "(" Arguments ")" ":" Suite [strict(2)]

endmodule
