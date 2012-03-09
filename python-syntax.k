module LITERALS
  syntax Imaginary ::= #Float "j"
  syntax Bytes ::= "b" #String
end module

module PYTHON-TOKENS imports LITERALS
  syntax NAME ::= #Id
  syntax NUMBER ::= #Int  | #Float | Imaginary
  syntax STRING ::= #String | Bytes
  syntax NAMES ::= List{NAME,","} [:seqstrict:] //TODO: remove
end module

module PYTHON-SYNTAX imports PYTHON-TOKENS

  syntax Atom ::= NAME
                | NUMBER
                | STRING
                | "tuple" "(" Expressions ")"        [:seqstrict required:]
                | "[" Expression CompIter "]"
                | "generator" "(" Expression CompIter ")"
                | "{" Expression CompIter "}"
                | "{" Expression ":" Expression CompIter "}"
                | "[" Expressions "]"        [:strict:]
                | "{" KeyData "}"        [:seqstrict:]
                | "{" Expressions "}"        [:seqstrict required:]
                | YieldExpression
                | "..."
  
  syntax CompFor ::= "for" Targets "in" Expressions [:required:]
  syntax CompIf ::= "if" "(" Expression ")"
  syntax CompIter ::= CompFor
                    | CompIf
                    | CompIter "::" CompIter [:strict(1):]

  syntax YieldExpression ::= "yield" Expression        [:strict:] 
                           | "yield"
  syntax KeyData ::= List{KeyDatum,","} [:seqstrict:]
  syntax KeyDatum ::= Expression ":" Expression [:prec 40 gather(e e) seqstrict hybrid:]

  syntax Primary ::= Atom
                   | AttributeRef
                   | Subscription
                   | Slicing
                   | Expression "(" Arguments ")" [:strict(1) prec 42:]

  syntax Arguments ::= List{Argument,","} [:seqstrict:]
  syntax Argument ::= Expression
                    | #Id "=" Expression
                    // "*" Expression is implicit
                    | "**" Expression

  syntax AttributeRef ::= Expression "." NAME [:strict(1) prec 42:]
  syntax Subscription ::= Expression "[" Expression "]" [:seqstrict required prec 42:]
  syntax Slicing ::= Expression "['" SliceItems "']" [:seqstrict required prec 42:]
  syntax SliceItems ::= List{SliceItem,","} [:seqstrict:]
  syntax SliceItem ::= Expression
                     | Expression ":" Expression ":" Expression [:seqstrict:]

  syntax Expression ::= Primary

  syntax Expression ::= Expression "**" Expression     [:seqstrict prec 43 gather(e E):]
                      | "-" Expression                 [:strict prec 44:]
                      | "+" Expression                 [:strict prec 44:]
                      | "~" Expression                 [:strict prec 44:]
                      | Expression "*" Expression      [:seqstrict prec 45 gather(E e):]
                      | Expression "floor/" Expression [:seqstrict prec 45 gather(E e):]
                      | Expression "/" Expression      [:seqstrict prec 45 gather(E e):]
                      | Expression "%" Expression      [:seqstrict prec 45 gather(E e):]
                      | Expression "+" Expression      [:seqstrict prec 46 gather(E e):]
                      | Expression "-" Expression      [:seqstrict prec 46 gather(E e):]
                      | Expression "<<" Expression     [:seqstrict prec 47 gather(E e):]
                      | Expression ">>" Expression     [:seqstrict prec 47 gather(E e):]
                      | Expression "&" Expression      [:seqstrict prec 48 gather(E e):]
                      | Expression "^" Expression      [:seqstrict prec 49 gather(E e):]
                      | Expression "|" Expression      [:seqstrict prec 50 gather(E e):]

  syntax Expression ::= Expression "<" Expression      [:strict(1) prec 51 gather(e E):]
                      | Expression ">" Expression      [:strict(1) prec 51 gather(e E):]
                      | Expression "==" Expression     [:strict(1) prec 51 gather(e E):]
                      | Expression ">=" Expression     [:strict(1) prec 51 gather(e E):]
                      | Expression "<=" Expression     [:strict(1) prec 51 gather(e E):]
                      | Expression "!=" Expression     [:strict(1) prec 51 gather(e E):]
                      | Expression "is" Expression     [:strict(1) prec 51 gather(e E):]
                      | Expression "is not" Expression [:strict(1) prec 51 gather(e E):]
                      | Expression "in" Expression     [:strict(1) prec 51 gather(e E):]
                      | Expression "not in" Expression [:strict(1) prec 51 gather(e E):]

  syntax Expression ::= "not" Expression               [:strict prec 52:]
                      | Expression "and" Expression    [:strict(1) prec 53 gather(E e):]
                      | Expression "or" Expression     [:strict(1) prec 54 gather(E e):]
                      | Expression "if" Expression "else" Expression [:strict(2) prec 55 gather(e e E):]

  syntax Expression ::= "lambda" Parameters ":" Expression [:prec 56:]
                      | "*" Expression [:prec 56:]

  syntax Expressions ::= List{Expression,","} [:prec 99 seqstrict:]

  syntax SimpleStmt ::= Expression ";" [:prec 60 gather(e) strict:]
                      | Targets ":=" Expression [:strict(2) required:]
                      | Target "+=" Expression        [:strict(2) required:]
                      | Target "-=" Expression        [:strict(2) required:]
                      | Target "*=" Expression        [:strict(2) required:]
                      | Target "/=" Expression        [:strict(2) required:]
                      | Target "floor/=" Expression   [:strict(2) required:]
                      | Target "%=" Expression        [:strict(2) required:]
                      | Target "**=" Expression       [:strict(2) required:]
                      | Target ">>=" Expression       [:strict(2) required:]
                      | Target "<<=" Expression       [:strict(2) required:]
                      | Target "&=" Expression        [:strict(2) required:]
                      | Target "^=" Expression        [:strict(2) required:]
                      | Target "|=" Expression        [:strict(2) required:]
                      | "assert" Expressions [:prec 60:]
                      | "pass"
                      | "del" Targets       [:required:]
                      | "return" Expression        [:strict(1):]
                      | "return"
                      | "raise"
                      | "raise" Expression [:strict prec 60:]
                      | "raise" Expression "from" Expression [:seqstrict:]
                      | "break"
                      | "continue"
                      | "import" ModuleAliases        [:seqstrict required:]
                      | "from" RelativeModule "import" ModuleAliases        [:strict(1) required:]
                      | "from" Module "import" "*"        [:strict:]
                      | "global" NAMES        [:strict required:]
                      | "nonlocal" NAMES      [:strict required:]

  syntax Targets ::= Expressions 
  syntax Target ::= Expression
  
  syntax ModuleAliases ::= List{ModuleAlias,","}
  syntax ModuleAlias ::= Module [:required:]
                       | Module "as" NAME
  syntax Module ::= NAME
                    NAME "." Module
  syntax RelativeModule ::= ".dir"
                          | Module [:required:]
                          | "." RelativeModule        [:strict:]

  syntax ExceptClauses ::= List{ExceptClause,"except"}

  syntax CompoundStmt ::= "if" Expression ":" Statements "else" ":" Statements        [:strict(1):]
                        | "while" Expression ":" Statements "else" ":" Statements
                        | "for" Targets "in" Expressions ":" Statements "else" ":" Statements        [:required:]
                        | "try" ":" Statements ExceptClauses "else" ":" Statements //"finally" ":" Statements
                        | "try" ":" Statements "finally" ":" Statements
                        | "with" Expression "as" Target ":" Statements
                        | Decorated
  syntax Statement ::=        SimpleStmt
                     |        CompoundStmt
  syntax Statements ::= Statement
                      | Statement "newline" Statements

  syntax ExceptClause ::=        "except" ":" Statements
                        |        "except" Expression ":" Statements [:strict(1) gather(e E):]
                        |        "except" Expression "as" NAME ":" Statements [:strict(1):]

  syntax Decorated ::=        ClassDef
                     |        FuncDef
                     |        "@" Primary "newline" Decorated

  syntax Parameters ::= List{Parameter,","} [:seqstrict:]
  syntax Parameter ::= Argument
                     | KeyDatum
                     | Argument ":" Expression [:ditto:]
                     | "*"

  syntax FuncDef ::= "def" NAME "(" Parameters ")" "->" Expression ":" Statements [:required strict(3):]
                   | "def" NAME "(" Parameters ")" ":" Statements [:required:]


  syntax ClassDef ::=        "class" NAME "(" Arguments ")" ":" Statements        [:seqstrict(2):]

end module
