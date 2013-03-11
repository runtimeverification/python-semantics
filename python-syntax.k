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
  //this conflicts with Argument ":" Exp below. Since I can tag all the rules
  //in python-semantics-functions.k to have Argument as their first sort (no
  //literal values are needed) I will go ahead and tag its inverse number with
  //prefer in order to force all '_:_ instances whose first argument is an Exp
  //to be KeyDatum. Ideally we would tag the KeyDatum as KeyDatum but the tool
  //doesn't support that yet.
  syntax KeyDatum ::= Exp ":" Exp [seqstrict, hybrid, prefer]

  syntax Arguments ::= List{Argument,","}
  syntax Argument ::= Exp
                    | NAME "=" Exp [strict(2), klabel('keyword)]
                    | "*" Exp
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

  //since sometimes NAME "=" Exp is an assignment statement and sometimes a
  //keyword argument, we make Target directly subsort Id to disambiguate.
  //Ideally we would tag terms with sorts though.
  syntax TargetAndExp ::= Id
                        | "tuple" "(" TargetAndExps ")" [strict, klabel('Tuple)]
                        | "[" TargetAndExps "]" [strict]
                        > Exp "." NAME [strict(1), left]
                        | Exp "[" Slice "]" [seqstrict, left]

  syntax Target ::= TargetAndExp
                  | "*" Target [strict, klabel('Starred)]
                  | "tuple" "(" Targets ")" [strict, klabel('Tuple)]
                  | "[" Targets "]" [strict]
  syntax TargetAndExps ::= NeList{TargetAndExp,","}
  syntax Targets ::= List{Target,","}
  syntax NeTargets ::= NeList{Target,","}
  syntax Targets ::= NeTargets
  syntax Exp ::= TargetAndExp

  syntax Exp ::= "(" Exp ")" [bracket]
                | NUMBER
                | STRING
                | "tuple" "(" Exps ")" [strict, klabel('Tuple)] //TODO: use List{Exp,","}
                | "[" Exp Comps "]"
                | "generator" "(" Exp Comps ")" [klabel('GeneratorExp)] //TODO: Use (__)
                | "{" Exp Comps "}"
                | "{" Exp ":" Exp Comps "}"
                | "[" Exps "]" [strict]
                | "{" KeyData "}" [strict]
                | "{" NeExps "}" [strict, klabel('Set)]
                | YieldExp
                | "..."

                   > Exp "." NAME           [strict(1), left]
                   | Exp "[" Slice "]" [seqstrict, left]
                   | Exp "(" Arguments ")"  [seqstrict, left]

                 > Exp "**" Exp [seqstrict, right]

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

  syntax AssignTargets ::= NeList{Target,"="} [klabel('targets), avoid]
  
  syntax Aliases ::= NeList{Alias,","}
  //TODO: separate with from import
  syntax Alias ::= Exp
                       | Exp "as" Exp [strict(1)]
  syntax RelativeModule ::= "." [onlyLabel]
                          | Exp
                          | "." RelativeModule

  syntax ExceptClauses ::= NeList{ExceptClause,""}

  syntax Stmt ::= Exp ";" [strict, klabel('Expr)] //TODO: subsort
                     //since many instances of Exp are also intsances of Target,
                     //this conflicts with AssignmentTargets itself. But we
                     //never use raw AssignmentTargets outside an assignment
                     //statement. So to fix this ambiguity (which never occurs
                     //in complete programs), we prefer the assignemnt statement
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
