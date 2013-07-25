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

                  > Exp "|" Exp [seqstrict, left, orexpr]

                  > Compare [klabel('Compare)]
                   > "not" Exp [strict, nottest]

                   > Exp "and" Exp [strict(1), left]

                  > Exp "or" Exp [strict(1), left]

                      > Exp "if" Exp "else" Exp [strict(2), right]
                      > "lambda" Parameters ":" Exp

  context 'Compare(HOLE)

  syntax priorities orexpr > compare > nottest
  syntax priorities compare > 'Compare

  syntax Compare ::= right:
                    Exp "<" Compare        [compare]
                  | Exp ">" Compare        [compare]
                  | Exp "==" Compare       [compare]
                  | Exp ">=" Compare       [compare]
                  | Exp "<=" Compare       [compare]
                  | Exp "!=" Compare       [compare]
                  | Exp "is" Compare       [compare]
                  | Exp "is" "not" Compare [compare]
                  | Exp "in" Compare       [compare]
                  | Exp "not" "in" Compare [compare]
                  | Exp "<" Exp        [compare, avoid]
                  | Exp ">" Exp        [compare, avoid]
                  | Exp "==" Exp       [compare, avoid]
                  | Exp ">=" Exp       [compare, avoid]
                  | Exp "<=" Exp       [compare, avoid]
                  | Exp "!=" Exp       [compare, avoid]
                  | Exp "is" Exp       [compare, avoid]
                  | Exp "is" "not" Exp [compare, avoid]
                  | Exp "in" Exp       [compare, avoid]
                  | Exp "not" "in" Exp [compare, avoid]

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

  syntax Stmt ::= Exp ";" [strict, klabel('Expr)] //TODO: subsort
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
                     > "if" Exp ":" Stmts
                     | "if" Exp ":" Stmts "else" ":" Stmts [strict(1)]
                     | "while" Exp ":" Stmts
                     | "while" Exp ":" Stmts "else" ":" Stmts
                     | "for" Target "in" Exp ":" Stmts
                     | "for" Target "in" Exp ":" Stmts "else" ":" Stmts
                     | "try" ":" Stmts ExceptClauses
                     | "try" ":" Stmts ExceptClauses "else" ":" Stmts //"finally" ":" Stmts
                     | "try" ":" Stmts ExceptClauses "else" ":" Stmts "finally" ":" Stmts
                     | "try" ":" Stmts "finally" ":" Stmts
                     | "with" Aliases ":" Stmts [strict(1)]
                     | Decorated

  syntax Stmts ::= Stmt
                      > List{Stmt,"newline"}

  syntax ExceptClause ::= "except" ":" Stmts
                        | "except" Exp ":" Stmts [strict(1)]
                        | "except" Exp "as" NAME ":" Stmts [strict(1)]

  syntax Decorated ::= ClassDef
                     | FuncDef
                     | "@" Exp Decorated [strict(1)]

  syntax Parameters ::= List{Parameter,","} [seqstrict]
  syntax Parameter ::= Argument
                     | Argument ":" Exp [klabel('annotation)]
                     | "*"

  syntax FuncDef ::= "def" NAME "(" Parameters ")" "->" Exp ":" Stmts
                   | "def" NAME "(" Parameters ")" ":" Stmts


  syntax ClassDef ::= "class" NAME "(" Arguments ")" ":" Stmts [strict(2)]

endmodule
